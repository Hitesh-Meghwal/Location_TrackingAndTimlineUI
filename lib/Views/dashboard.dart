import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sampleapp/Views/google_map.dart';
import 'package:sampleapp/Views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';
import '../Models/user_model.dart';
import '../Services/Database/database_service.dart';

class Dashboard extends StatefulWidget {
  final String username;

  const Dashboard({super.key, required this.username});

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {
  final DatabaseService _DatabaseService = DatabaseService.instance;

  late String _userName = "";
  List<User> _userTimeline = [];
  late Timer _locationUpdateTimer;


  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _getUserData();
  }

  // Cancel the timer to prevent leaks, when widget no longer use
  @override
  void dispose(){
    _locationUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, $_userName'),
          actions: [
            IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _timeLineUI(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getUserData() async {
    final users = await _DatabaseService.getUserByUsername(widget.username);
    if (users.isNotEmpty) {
      setState(() {
        _userName = users.first.userName;
        _userTimeline = users;
      });
    }
  }

  void _startLocationUpdates(){
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30),(timer){
      _updateLocation();
    });
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      String timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString();
      String positionString = "${position.latitude},${position.longitude}";

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        Placemark placemark = placemarks.first;
        String _locationName = placemark.locality ??
              placemark.administrativeArea ??
              'Unknown Location';
        // Save the location to the database
        _DatabaseService.addUser(
          widget.username.trim(),
          positionString,
          _locationName,
          timestamp,
        );
      // Optionally update the state to reflect the new location in the UI
      setState(() {
        _userTimeline.add(User(
          widget.username,
          positionString,
          _locationName,
          timestamp,
        ));
      });

      print("Location updated: $positionString");
    } catch (e) {
      print("Failed to get location: $e");
    }
  }


  Widget _timeLineUI() {
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connectedFromStyle(
        contentsAlign: ContentsAlign.alternating,
        oppositeContentsBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(28.0),
          child: Text(
              '${_userTimeline[index].userName}\n ${_userTimeline[index].userTimestamp}'),
        ),
        contentsBuilder: (context, index) => GestureDetector(
          onTap: () {
            final userLocation = _userTimeline[index].userlatLng;
            if (userLocation.isNotEmpty) {
              final latlng = userLocation.split(",");
              final latitude = double.parse(latlng[0]);
              final longitude = double.parse(latlng[1]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoogleMapScreen(
                    latitude: latitude,
                    longitude: longitude,
                  ),
                ),
              );
            }
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(_userTimeline[index].userLocation ?? 'Loading...'),
            ),
          ),
        ),
        connectorStyleBuilder: (context, index) => ConnectorStyle.solidLine,
        indicatorStyleBuilder: (context, index) => IndicatorStyle.dot,
        itemCount: _userTimeline.length,
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timelines/timelines.dart';
import '../Models/user_model.dart';
import '../Services/Database/database_service.dart';

class Dashboard extends StatefulWidget {

  const Dashboard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {

  final DatabaseService _DatabaseService = DatabaseService.instance;

  late String _locationName = "";
  late String _userName = "";
  late String _timestamp = "";
  late Position _currentPos;
  late double _deviceWidth, _deviceHeight;
  List<User> _userTimeline = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, $_userName'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // _showDetails(),
              _timeLineUI(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getUserData() async {
    final users = await _DatabaseService.getUser();
    if(users.isNotEmpty){
      final user = users.last;

      setState(() {
        _userName = user.userName;
        _timestamp = user.userTimestamp;
        final locationParts = user.userLocation.split(',');
        _currentPos = Position(
          latitude: double.parse(locationParts[0]),
          longitude: double.parse(locationParts[1]),
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0, altitudeAccuracy: 0.0, headingAccuracy: 0.0 ,
        );
        _userTimeline = users;
      });

      _getLocationName();
    }
  }


  Future<void> _getLocationName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPos.latitude,
        _currentPos.longitude,
      );
      Placemark placemark = placemarks.first;
      setState(() {
        _locationName = placemark.name ?? '';
      });
    } catch (e) {
      print('Error getting location name: $e');
    }
  }


  Widget _timeLineUI(){
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connectedFromStyle(
        contentsAlign: ContentsAlign.alternating,
        oppositeContentsBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(28.0),
          child: Text('$_userName\n $_timestamp'),
        ),
        contentsBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(_locationName),
          ),
        ),
        connectorStyleBuilder: (context, index) => ConnectorStyle.solidLine,
        indicatorStyleBuilder: (context, index) => IndicatorStyle.dot,
        itemCount: _userTimeline.length ,
      ),
    );
  }
}

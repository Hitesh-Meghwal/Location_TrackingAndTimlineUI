import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sampleapp/Models/user_model.dart';
import 'package:sampleapp/Services/Database/database_service.dart';
import 'package:sampleapp/Views/google_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final DatabaseService _DatabaseService = DatabaseService.instance;

  List<User> _userTimeline = [];
  late String _locationName = "";
  var userName = "";
  late double _deviceWidth, _deviceHeight;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _geoLocator();
  }

  _geoLocator() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location Services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permission are permanently denied');
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
      _getLocationNames();
    } catch (e) {
      print("Failed to get location $e");
    }
  }

  Future<void> _getLocationNames() async {
    try {
      if (_currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        Placemark placemark = placemarks.first;
        setState(() {
          _locationName = placemark.locality ??
              placemark.administrativeArea ??
              'Unknown Location';
        });
      }
    } catch (e) {
      print('Error getting location names: $e');
    }
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    String? savedUserName = prefs.getString('username');
    if (isLoggedIn != null && isLoggedIn && savedUserName != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Dashboard(username: savedUserName)));
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                  width: _deviceWidth * 0.9,
                  height: _deviceHeight * 0.48,
                  child: SvgPicture.asset("assets/image/appLogo.svg")),
              _textview(),
              _button()
            ],
          ),
        ),
      ),
    );
  }

  Widget _textview() {
    return Center(
      child: Container(
        width: _deviceWidth * 0.85,
        height: _deviceHeight * 0.1,
        child: TextFormField(
          decoration: const InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            suffixIcon: Icon(
              Icons.email,
              color: Colors.grey,
            ),
            labelText: 'UserName',
            labelStyle: TextStyle(color: Colors.green),
          ),
          onChanged: (value) {
            userName = value;
          },
        ),
      ),
    );
  }

  Widget _button() {
    return Padding(
      padding: EdgeInsets.only(left: _deviceWidth * 0.5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
        child: const Text(
          "Submit",
          style: TextStyle(
              color: Colors.black, fontSize: 19, fontWeight: FontWeight.w500),
        ),
        onPressed: () async {
          if (userName.isNotEmpty) {
            if (_currentPosition != null) {
              await _geoLocator();
              String timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString();
              String positionString = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
              _DatabaseService.addUser(
                  userName.trim(), positionString, _locationName, timestamp);
              print("Data added");
              // Set login status and username in shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              await prefs.setString('username', userName);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(username: userName)));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Please enter Username to proceed",
                  style: TextStyle(
                      fontSize: _deviceWidth * 0.03, color: Colors.green),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}

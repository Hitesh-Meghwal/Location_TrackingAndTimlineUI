import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sampleapp/Services/Database/database_service.dart';
import 'package:sampleapp/Widgets/videoWidget.dart';

import 'dashboard.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {

  final DatabaseService _DatabaseService = DatabaseService.instance;

  var userName = "";
  late double _deviceWidth, _deviceHeight;
  Position? _currentPosition;
  @override
  void initState() {
    super.initState();
    _geoLocator();
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

  _geoLocator() async{
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error('Location Services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error('Location permission are denied');
      }
    }
    
    if(permission == LocationPermission.deniedForever){
      return Future.error('Location permission are permanently denied');
    }

    try{
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    }
    catch(e){
      print("Failed to get location $e");
    }
  }

  Widget _textview() {
    return Center(
      child: Container(
        width: _deviceWidth * 0.85,
        height: _deviceHeight * 0.1,
        child: TextFormField(
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green)
            ),
            suffixIcon: Icon(
              Icons.email,
              color: Colors.grey,
            ),
            labelText: 'UserName',
            labelStyle: TextStyle(color: Colors.green),
          ),
          onChanged: (value){
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200]
        ),
        child: const Text(
          "Submit",
          style: TextStyle(
              color: Colors.green,
              fontSize: 19,
              fontWeight: FontWeight.w500
          ),
        ),
        onPressed: () {
          if (userName.isNotEmpty) {
            if (_currentPosition != null){
              String timestamp = DateTime.now().toString();
              String positionString = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
              _DatabaseService.addUser(userName, positionString, timestamp);
              print("Data added");
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Dashboard()));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Please enter Username to proceed",
                  style: TextStyle(
                      fontSize: _deviceWidth * 0.03,
                      color: Colors.green
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                ),
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

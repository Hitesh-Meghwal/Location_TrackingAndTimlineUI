import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sampleapp/dashboard.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  var userName = TextEditingController();
  late double _deviceWidth, _deviceHeight;
  late Position _currentPosition;
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
        body: Column(
          children: [
            _textview(),
            _button()
          ],
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

    _currentPosition = await Geolocator.getCurrentPosition();
  }

  Widget _textview() {
    return Padding(
      padding: EdgeInsets.only(top: _deviceHeight * 0.2),
      child: Center(
        child: Container(
          width: _deviceWidth * 0.85,
          height: _deviceHeight * 0.3,
          child: TextFormField(
            controller: userName,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green)
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green)
              ),
              suffixIcon: Icon(
                Icons.email,
                color: Colors.grey,
              ),
              labelText: 'UserName',
              labelStyle: TextStyle(color: Colors.green),
            ),
          ),
        ),
      ),
    );
  }

  Widget _button() {
    return ElevatedButton(
      child: Text(
        "Submit",
        style: TextStyle(
            color: Colors.green,
            fontSize: 19,
            fontWeight: FontWeight.w500
        ),
      ),
      onPressed: () {
        if (userName.text.isNotEmpty) {
          String timestamp = DateTime.now().toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(
                userName: userName.text,
                timeStamp: timestamp,
                currentPos: _currentPosition
              ),
            ),
          );
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
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}

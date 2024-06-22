import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Dashboard extends StatefulWidget {
  final String userName;
  final String timeStamp;
  final Position currentPos;

  const Dashboard({super.key, required this.userName, required this.timeStamp, required this.currentPos});

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {
  late double _deviceWidth, _deviceHeight;
  late String _locationName = "" ;

  @override
  void initState() {
    super.initState();
    _getLocationName();
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, ${widget.userName}'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Current Timestamp: ${widget.timeStamp}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            _showDetails(),
          ],
        ),
      ),
    );
  }


  Future<void> _getLocationName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.currentPos.latitude,
        widget.currentPos.longitude,
      );
      Placemark placemark = placemarks.first;
      setState(() {
        _locationName = placemark.name ?? '';
      });
    } catch (e) {
      print('Error getting location name: $e');
    }
  }

  Widget _showDetails() {
    String locationText = 'Latitude: ${widget.currentPos.latitude}, Longitude: ${widget.currentPos.longitude}';
    return Padding(
      padding: EdgeInsets.only(top: _deviceHeight * 0.2,),
      child: Container(
        child: Table(
          defaultColumnWidth: FixedColumnWidth(120),
          border: TableBorder.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: 2,
          ),
          children: [
            const TableRow(
              children: [
                Center(
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Time",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Center(
                  child: Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    widget.timeStamp,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    locationText,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

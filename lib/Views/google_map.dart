import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sampleapp/Models/user_model.dart';
import 'package:sampleapp/Services/Database/database_service.dart';

class GoogleMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const GoogleMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = LatLng(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 10,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("_currentLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: _currentLocation,
              ),
            },
          ),
        ),
      ),
    );
  }
}

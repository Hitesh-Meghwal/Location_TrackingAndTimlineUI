import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final LatLng _center = const LatLng(19.076090, 72.877426); // Coordinates for Mumbai

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 10,
            ),
            markers: {
              Marker(
                markerId: MarkerId("_previousLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: _center,
              ),
              Marker(
                markerId: MarkerId("_currentLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: _center,
              ),
            },
          ),
        ),
      ),
    );
  }
}

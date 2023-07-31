import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({Key? key}) : super(key: key);

  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController googleMapController;
  double? latitude;
  double? longitude;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng? currentLatLng = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps')),
      body: Stack(
        children: [
          if (currentLatLng != null)
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: currentLatLng, zoom: 10),
              onMapCreated: _createMap,
            ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _createMap(GoogleMapController gmController) {
    googleMapController = gmController;
  }
}

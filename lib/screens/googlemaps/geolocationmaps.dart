import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GeoLocationMaps {
  static String googleMapsURL = '';
  static String latitude = '';
  static String longitude = '';
  Future<Position> getCurrentLocation() async {
    EasyLoading.show();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
          'Location service is disabled. Please enable location service.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission permanently denied. Please enable location service.');
    }
    EasyLoading.dismiss();
    return await Geolocator.getCurrentPosition();
  }

  void liveLocation() {
    Geolocator.getCurrentPosition();
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 100);
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  Future<void> openGoogleMaps(
          context, String latitude, longitude, setState) async =>
      showDialog(
          context: context,
          builder: (_) => confirmDialog(context, 'CHECK ON GOOGLE MAPS',
                  'If the location is correct, tap on "Share" to copy your location and paste it in "Google Maps URL" field.',
                  () async {
                setState(() => googleMapsURL =
                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                await canLaunchUrl(Uri.parse(googleMapsURL))
                    ? await launchUrlString(googleMapsURL)
                    : showDialog(
                        context: context,
                        builder: (_) =>
                            errorDialog(context, 'Invalid Google Maps URL!'));
              }));
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/main.dart';
import 'package:marketdo_app/screens/authentication/landing.dart';
import 'package:marketdo_app/screens/googlemaps/geolocationmaps.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

const List<String> list = <String>['Yes', 'No'];

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseService _services = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final _customerName = TextEditingController();
  final _contactNumber = TextEditingController();
  final _address = TextEditingController();
  final _landMark = TextEditingController();
  final _googleMapsURL = TextEditingController();
  // ignore: unused_field
  String? _bName;
  XFile? coverPhoto;
  String? displayImage;
  XFile? logo;
  String? logoUrl;

  final ImagePicker _picker = ImagePicker();

  Widget _formField(
          {TextEditingController? controller,
          String? label,
          TextInputType? type,
          String? Function(String?)? validator}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: label,
                prefixText: controller == _contactNumber ? '+63' : null),
            validator: validator,
            onChanged: (value) {
              if (controller == _customerName) {
                setState(() => _bName = value);
              }
            }),
      );

  Future<XFile?> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  _scaffold(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () => ScaffoldMessenger.of(context).clearSnackBars())));
  }

  _saveToDB() {
    if (coverPhoto == null) {
      _scaffold('Customer Image not selected');
      return;
    }

    if (_formKey.currentState!.validate()) {
      {
        EasyLoading.show(status: 'Please wait...');
        _services
            .uploadImage(coverPhoto, 'customers/$authID/cover.jpg')
            .then((String? url) {
          if (url != null) {
            setState(() => displayImage = url);
          }
        }).then((value) => _services
                .uploadImage(logo, 'customers/$authID/logo.jpg')
                .then((url) => setState(() => logoUrl = url))
                .then((value) => _services.addCustomer(data: {
                      'address': _address.text,
                      'coverPhoto': displayImage,
                      'customerID': authID,
                      'email': FirebaseAuth.instance.currentUser!.email,
                      'isOnline': 'true',
                      'landMark': _landMark.text,
                      'location': _googleMapsURL.text,
                      'logo': logoUrl,
                      'mobile': '+63${_contactNumber.text}',
                      'name': _customerName.text,
                      'registeredOn': DateTime.now(),
                    }).then((value) {
                      EasyLoading.dismiss();
                      return Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LandingScreen()));
                    })));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Form(
      key: _formKey,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
              child: Column(children: [
            SizedBox(
                height: 240,
                child: Stack(alignment: Alignment.center, children: [
                  coverPhoto == null
                      ? Container(color: Colors.greenAccent, height: 240)
                      : InkWell(
                          onTap: () => _pickImage().then(
                              (value) => setState(() => coverPhoto = value)),
                          child: Container(
                              padding: const EdgeInsets.all(20),
                              height: 240,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(File(coverPhoto!.path)),
                                      fit: BoxFit.cover)))),
                  Row(children: [
                    const SizedBox(width: 20),
                    Stack(children: [
                      logo == null
                          ? Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Center(
                                  child: Text('YOUR\nPROFILE\nPICTURE',
                                      textAlign: TextAlign.center)))
                          : Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  image: DecorationImage(
                                      image: FileImage(File(logo!.path)),
                                      fit: BoxFit.cover))),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                              onTap: () => _pickImage().then(
                                  (value) => setState(() => logo = value)),
                              child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white))))
                    ])
                  ]),
                  Positioned(
                      bottom: 10,
                      right: 10,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.8)),
                          onPressed: () => _pickImage().then(
                              (value) => setState(() => coverPhoto = value)),
                          child: const Text('Edit cover photo',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold))))
                ])),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                child: Column(children: [
                  _formField(
                      controller: _customerName,
                      label: 'Enter your full name',
                      type: TextInputType.text,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter Your Name' : null),
                  _formField(
                      controller: _contactNumber,
                      label: 'Contact Number',
                      type: TextInputType.phone,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter Contact Number' : null),
                  _formField(
                      controller: _address,
                      label: 'Address',
                      type: TextInputType.text,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter Address' : null),
                  _formField(
                      controller: _landMark,
                      label: 'Landmark',
                      type: TextInputType.text,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a Landmark' : null),
                  ElevatedButton(
                      onPressed: () =>
                          GeoLocationMaps().getCurrentLocation().then((value) {
                            GeoLocationMaps.latitude =
                                value.latitude.toString();
                            GeoLocationMaps.longitude =
                                value.longitude.toString();
                            setState(() {
                              GeoLocationMaps.googleMapsURL =
                                  'https://www.google.com/maps/search/?api=1&query=${GeoLocationMaps.latitude},${GeoLocationMaps.longitude}';
                              _googleMapsURL.text =
                                  GeoLocationMaps.googleMapsURL;
                            });
                            GeoLocationMaps().liveLocation();
                          }),
                      child: const Text('Set my location')),
                  if (GeoLocationMaps.googleMapsURL.isNotEmpty)
                    _formField(
                        label: 'Google Maps URL', controller: _googleMapsURL),
                  if (GeoLocationMaps.latitude.isNotEmpty &&
                      GeoLocationMaps.longitude.isNotEmpty)
                    ElevatedButton(
                        onPressed: () => GeoLocationMaps().openGoogleMaps(
                            context,
                            GeoLocationMaps.latitude,
                            GeoLocationMaps.longitude,
                            setState),
                        child: const Text('Check on Google Maps'))
                ]))
          ])),
          persistentFooterButtons: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(
                  width: 120,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.red.shade900),
                      onPressed: () => FirebaseAuth.instance
                          .signOut()
                          .then((value) =>
                              updateCustomerOnlineStatus(authID, false))
                          .then((value) => setState(
                              () => FirebaseAuth.instance.currentUser == null)),
                      child: const Text('Logout'))),
              Container(
                  width: 120,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                      onPressed: _saveToDB, child: const Text('Register')))
            ])
          ]));
}

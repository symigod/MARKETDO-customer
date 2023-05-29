import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketdo_app/firebase_services.dart';
import 'package:marketdo_app/screens/landing_screen.dart';

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
  final _email = TextEditingController();
  final _landMark = TextEditingController();
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
      TextFormField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
              labelText: label,
              prefixText: controller == _contactNumber ? '+63' : null),
          validator: validator,
          onChanged: (value) {
            if (controller == _customerName) {
              setState(() => _bName = value);
            }
          });

  Future<XFile?> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  _scaffold(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'OK',
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
            .uploadImage(
                coverPhoto, 'customers/${_services.user!.uid}/cover.jpg')
            .then((String? url) {
          if (url != null) {
            setState(() => displayImage = url);
          }
        }).then((value) => _services
                    .uploadImage(
                        logo, 'customers/${_services.user!.uid}/logo.jpg')
                    .then((url) => setState(() => logoUrl = url))
                    .then((value) {
                  return _services.addCustomer(data: {
                    'coverPhoto': displayImage,
                    'logo': logoUrl,
                    'name': _customerName.text,
                    'mobile': '+63${_contactNumber.text}',
                    'address': _address.text,
                    'email': _email.text,
                    'landMark': _landMark.text,
                    'approved': true,
                    'time': DateTime.now(),
                  }).then((value) {
                    EasyLoading.dismiss();
                    return Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const LandingScreen()));
                  });
                }));
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
                child: Stack(children: [
                  coverPhoto == null
                      ? Container(
                          color: Colors.greenAccent,
                          height: 240,
                          child: TextButton(
                              child: Center(
                                  child: Text('Tap to add cover photo',
                                      style: TextStyle(
                                          color: Colors.grey.shade800))),
                              onPressed: () => _pickImage().then((value) =>
                                  setState(() => coverPhoto = value))))
                      : InkWell(
                          onTap: () => _pickImage().then(
                              (value) => setState(() => coverPhoto = value)),
                          child: Container(
                              height: 240,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  image: DecorationImage(
                                      opacity: 100,
                                      image: FileImage(File(coverPhoto!.path)),
                                      fit: BoxFit.cover)))),
                  SizedBox(
                      height: 80,
                      child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          actions: [
                            IconButton(
                                onPressed: () =>
                                    FirebaseAuth.instance.signOut(),
                                icon: const Icon(Icons.exit_to_app))
                          ])),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                    onTap: () => _pickImage().then((value) =>
                                        setState(() => logo = value)),
                                    child: Card(
                                        elevation: 4,
                                        child: logo == null
                                            ? const SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Center(child: Text('+')))
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: SizedBox(
                                                    height: 50,
                                                    width: 50,
                                                    child: Image.file(
                                                        File(logo!.path)))))),
                                const SizedBox(width: 10),
                                Text(_bName == null ? '' : _bName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20))
                              ])))
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
                      type: TextInputType.phone,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter Address' : null),
                  _formField(
                      controller: _email,
                      label: 'Email Address',
                      type: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter email';
                        }
                        bool isValid = (EmailValidator.validate(value));
                        if (isValid == false) {
                          return 'Invalid Email';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  _formField(
                      controller: _landMark,
                      label: 'Landmark',
                      type: TextInputType.text,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a Landmark' : null),
                  const SizedBox(height: 10)
                ]))
          ])),
          persistentFooterButtons: [
            Row(children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: _saveToDB, child: const Text('Register'))))
            ])
          ]));
}

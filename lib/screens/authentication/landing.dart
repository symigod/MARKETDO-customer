import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/screens/main.screen.dart';
import 'package:marketdo_app/screens/authentication/register.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: customersCollection.doc(authID).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return errorWidget(snapshot.error.toString());
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingWidget();
              }
              if (snapshot.hasData) {
                return const MainScreen();
              }
              return const RegistrationScreen();
            }));
  }
}

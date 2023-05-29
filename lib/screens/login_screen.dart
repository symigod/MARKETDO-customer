import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:marketdo_app/screens/landing_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) => !snapshot.hasData
          ? SignInScreen(
              headerBuilder: (context, constraints, _) => const Padding(
                  padding: EdgeInsets.all(20),
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                          child: Text('Marketdo App',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)))),
              subtitleBuilder: (context, action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(action == AuthAction.signIn
                      ? 'Welcome to Marketdo App - Customer! \nPlease sign in to continue.'
                      : 'Welcome to Customer-App! \nPlease create an account to continue')),
              footerBuilder: (context, _) => const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                      'By signing in, you agree to our terms and conditions.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center)),
              providerConfigs: const [
                  EmailProviderConfiguration(),
                  GoogleProviderConfiguration(
                      clientId:
                          '1:780102967000:android:af3d1b7fd390ef64e901ad'),
                  PhoneProviderConfiguration()
                ])
          : const LandingScreen());
}

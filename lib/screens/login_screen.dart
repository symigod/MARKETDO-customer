import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:marketdo_app/screens/landing_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      // If the user is already signed-in, use it as initial data
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return SignInScreen(

              headerBuilder: (context, constraints, _) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: Text(
                        'Marketdo App', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),),
                  ),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    action == AuthAction.signIn
                        ? 'Welcome to Marketdo App - Customer! \nPlease sign in to continue.'
                        : 'Welcome to Customer-App! \nPlease create an account to continue',
                  ),
                );
              },
              footerBuilder: (context, _) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'By signing in, you agree to our terms and conditions.',
                    style: TextStyle(color: Colors.grey),textAlign: TextAlign.center,
                  ),
                );
              },

              providerConfigs: const [
                EmailProviderConfiguration(),
                GoogleProviderConfiguration(clientId: '1:780102967000:android:af3d1b7fd390ef64e901ad'),
                PhoneProviderConfiguration()
              ]
          );
        }

        // Render your application if authenticated
        return const LandingScreen();
      },
    );
  }
}

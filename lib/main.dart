import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/screens/authentication/login.dart';
import 'package:marketdo_app/screens/main.screen.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/screens/authentication/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';

int marketDoGreen = 0xFF1B5E20;
MaterialColor _marketDoGreen = MaterialColor(marketDoGreen, {
  50: const Color(0xFFE8F5E9),
  100: const Color(0xFFC8E6C9),
  200: const Color(0xFFA5D6A7),
  300: const Color(0xFF81C784),
  400: const Color(0xFF66BB6A),
  500: Color(marketDoGreen),
  600: const Color(0xFF43A047),
  700: const Color(0xFF388E3C),
  800: const Color(0xFF2E7D32),
  900: const Color(0xFF1B5E20)
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(const MyApp());
}

void updateCustomerOnlineStatus(String? authID, bool isOnline) {
  customersCollection
      .doc(authID)
      .update({'isOnline': isOnline})
      .then((value) => isOnline == true
          ? print('CUSTOMER ONLINE')
          : print('CUSTOMER OFFLINE'))
      .catchError(
          (error) => print('Failed to update customer online status: $error'));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      updateCustomerOnlineStatus(authID, true);
    } else {
      updateCustomerOnlineStatus(authID, false);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: _marketDoGreen, fontFamily: 'Lato'),
          home: const SplashScreen(),
          builder: EasyLoading.init(),
          routes: {
            OnBoardingScreen.id: (context) => const OnBoardingScreen(),
            LoginScreen.id: (context) => const LoginScreen(),
            MainScreen.id: (context) => const MainScreen()
          });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String id = 'splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final store = GetStorage();

  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      bool? boarding = store.read('onBoarding');
      boarding == null
          ? Navigator.pushReplacementNamed(context, OnBoardingScreen.id)
          : boarding == true
              ? Navigator.pushReplacementNamed(context, LoginScreen.id)
              : Navigator.pushReplacementNamed(context, OnBoardingScreen.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/marketdoLogo.png',
              height: 100, width: 100),
          const SizedBox(height: 10),
          const Text('MarketDo\nCustomer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2))
        ])));
  }
}

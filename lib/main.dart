import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marketdo_app/screens/login_screen.dart';
import 'package:marketdo_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketdo_app/screens/on_boarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';

// to generate id by date
String generateID() => DateTime.now().microsecondsSinceEpoch.toString();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  print('GENERATED ID: ${generateID()}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Lato'),
      initialRoute: SplashScreen.id,
      builder: EasyLoading.init(),
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        OnBoardingScreen.id: (context) => const OnBoardingScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        MainScreen.id: (context) => const MainScreen(),
      },
    );
  }
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
    Timer(
      const Duration(seconds: 3),
      () {
        bool? _boarding = store.read('onBoarding');
        _boarding == null
            ? Navigator.pushReplacementNamed(context, OnBoardingScreen.id)
            : _boarding == true
                ? Navigator.pushReplacementNamed(context, LoginScreen.id)
                : Navigator.pushReplacementNamed(context, OnBoardingScreen.id);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/marketdoLogo.png',
            height: 50,
            width: 60,
          ),
        ),
      ),
    );
  }
}

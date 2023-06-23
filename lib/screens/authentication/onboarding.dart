import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marketdo_app/screens/main.screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);
  static const String id = 'onboard-screen';

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  double scrollerPosition = 0;
  final store = GetStorage();

  onButtonPressed(context) {
    store.write('onBoarding', true);
    return Navigator.pushReplacementNamed(context, MainScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
        body: Stack(children: [
      PageView(
          onPageChanged: (val) =>
              setState(() => scrollerPosition = val.toDouble()),
          children: [
            OnBoardPage(
                bordColumn: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Welcome\nTo MarketdoApp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32)),
              const SizedBox(height: 10),
              const Text('+1000 Products\n+10 Categories',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                      fontSize: 28)),
              const SizedBox(height: 20),
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/3.png'))
            ])),
            OnBoardPage(
                bordColumn: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('7 - 14 Days Return',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32)),
              const SizedBox(height: 10),
              const Text('Satisfaction Guaranteed',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 20),
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/2.png'))
            ])),
            OnBoardPage(
                bordColumn: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Find your Favourite\n Products',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32)),
              const SizedBox(height: 20),
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/1.png'))
            ])),
            OnBoardPage(
                bordColumn: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Experience Smart\n Shopping',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32)),
              const SizedBox(height: 20),
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/4.png'))
            ])),
            OnBoardPage(
                bordColumn: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Safe & Secure\n Payments',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32)),
              const SizedBox(height: 20),
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/5.png'))
            ]))
          ]),
      Align(
          alignment: Alignment.bottomCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DotsIndicator(
                dotsCount: 5,
                position: scrollerPosition.toInt(),
                decorator: const DotsDecorator(activeColor: Colors.white)),
            scrollerPosition == 4
                ? Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.deepOrange)),
                        child: const Text('Start Shopping'),
                        onPressed: () => onButtonPressed(context)))
                : TextButton(
                    child: const Text('SKIP TO THE APP >',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    onPressed: () => onButtonPressed(context)),
            const SizedBox(height: 20)
          ]))
    ]));
  }
}

class OnBoardPage extends StatelessWidget {
  final Column? bordColumn;
  const OnBoardPage({Key? key, this.bordColumn}) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(children: [
        Container(color: Colors.greenAccent, child: Center(child: bordColumn)),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.blueGrey[700],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100)))))
      ]);
}

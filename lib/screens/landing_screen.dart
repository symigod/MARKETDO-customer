import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/screens/main_screen.dart';
import 'package:marketdo_app/screens/register_screen.dart';
import 'package:marketdo_app/widgets/api_widgets.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('customers')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return errorWidget(snapshot.error.toString());
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingWidget();
              }
              if (snapshot.hasData) {
                // Map<String, dynamic> customer =
                //     snapshot.data!.data() as Map<String, dynamic>;
                return const MainScreen();
                // if (customer['isApproved'] == true) {
                //   return const MainScreen();
                // }
                // return Center(
                //     child: Padding(
                //         padding: const EdgeInsets.all(20.0),
                //         child:
                //             Column(mainAxisSize: MainAxisSize.min, children: [
                //           SizedBox(
                //               height: 80,
                //               width: 80,
                //               child: ClipRRect(
                //                   borderRadius: BorderRadius.circular(4),
                //                   child: CachedNetworkImage(
                //                       imageUrl: customer['logo'],
                //                       placeholder: (context, url) => Container(
                //                           height: 100,
                //                           width: 100,
                //                           color: Colors.grey.shade300)))),
                //           const SizedBox(height: 10),
                //           Text(customer['name'],
                //               style: const TextStyle(
                //                   fontSize: 22, fontWeight: FontWeight.bold)),
                //           const SizedBox(height: 10),
                //           const Text(
                //               'Your application sent to Marketdo App Admin\nAdmin will contact you soon',
                //               textAlign: TextAlign.center,
                //               style:
                //                   TextStyle(fontSize: 18, color: Colors.grey)),
                //           OutlinedButton(
                //               style: ButtonStyle(
                //                   shape: MaterialStateProperty.all(
                //                       RoundedRectangleBorder(
                //                           borderRadius:
                //                               BorderRadius.circular(4)))),
                //               onPressed: () => FirebaseAuth.instance
                //                   .signOut()
                //                   .then((value) => Navigator.of(context)
                //                       .pushReplacement(MaterialPageRoute(
                //                           builder: (BuildContext context) =>
                //                               const LoginScreen()))),
                //               child: const Text('Sign out'))
                //         ])));
              }
              return const RegistrationScreen();
            }));
  }
}

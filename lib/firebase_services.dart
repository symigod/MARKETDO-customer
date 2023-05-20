import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class FirebaseService{

  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference customer = FirebaseFirestore.instance.collection('customer');
  CollectionReference homeBanner = FirebaseFirestore.instance.collection('homeBanner');
  CollectionReference brandAd = FirebaseFirestore.instance.collection('brandAd');
  CollectionReference categories = FirebaseFirestore.instance.collection('categories');
  CollectionReference mainCategories = FirebaseFirestore.instance.collection('mainCategories');
  CollectionReference subCategories = FirebaseFirestore.instance.collection('subCategories');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  
  static var instance;
  
  Future<String> uploadImage (XFile? file, String? reference) async {
    File _file = File(file!.path);

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref(reference);
    await ref.putFile(_file);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
    }

  Future<void> addCustomer({Map<String, dynamic>? data}) {
    // Call the user's CollectionReference to add a new user
    return customer.doc(user!.uid)
        .set(data)
        .then((value) => print("User Added"));
        // .catchError((error) => print("Failed to add user: $error"));
  }

  
Future<void> addOrder({required Map<String, dynamic> data}) {
    return orders.add(data).then((value) => print("Order added"));
  }



  String formattedNumber(number){
    var f = NumberFormat('##,###');
    String formattedNumber = f.format(number);
    return formattedNumber;
  }
}
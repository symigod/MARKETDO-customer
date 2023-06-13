import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

String? authID = FirebaseAuth.instance.currentUser!.uid;
CollectionReference cartsCollection =
    FirebaseFirestore.instance.collection('carts');
CollectionReference categoriesCollection =
    FirebaseFirestore.instance.collection('categories');
CollectionReference customersCollection =
    FirebaseFirestore.instance.collection('customers');
CollectionReference favoritesCollection =
    FirebaseFirestore.instance.collection('favorites');
CollectionReference homeBannerCollection =
    FirebaseFirestore.instance.collection('homeBanner');
CollectionReference ordersCollection =
    FirebaseFirestore.instance.collection('orders');
CollectionReference productsCollection =
    FirebaseFirestore.instance.collection('products');
CollectionReference vendorsCollection =
    FirebaseFirestore.instance.collection('vendors');

class FirebaseService {
  static var instance;

  Future<String> uploadImage(XFile? file, String? reference) async {
    File file0 = File(file!.path);

    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref(reference);
    await ref.putFile(file0);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> addCustomer({Map<String, dynamic>? data}) {
    // Call the user's CollectionReference to add a new user
    return customersCollection
        .doc(authID)
        .set(data)
        .then((value) => print("User Added"));
    // .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addOrder({required Map<String, dynamic> data}) {
    return ordersCollection.add(data).then((value) => print("Order added"));
  }

  String formattedNumber(number) {
    var f = NumberFormat('##,###');
    String formattedNumber = f.format(number);
    return formattedNumber;
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

String? authID = FirebaseAuth.instance.currentUser!.uid;
final cartsCollection = FirebaseFirestore.instance.collection('carts');
final categoriesCollection =
    FirebaseFirestore.instance.collection('categories');
final customersCollection = FirebaseFirestore.instance.collection('customers');
final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
final homeBannerCollection =
    FirebaseFirestore.instance.collection('homeBanner');
final ordersCollection = FirebaseFirestore.instance.collection('orders');
final productsCollection = FirebaseFirestore.instance.collection('products');
final vendorsCollection = FirebaseFirestore.instance.collection('vendors');

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

  Future<void> addCustomer({Map<String, dynamic>? data}) =>
      customersCollection.doc(authID).set(data!);

  Future<void> addOrder({required Map<String, dynamic> data}) =>
      ordersCollection.add(data);

  String formattedNumber(number) => NumberFormat('##,###').format(number);
}

// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final customerID;
  final favoriteID;
  final productID;

  FavoriteModel(
      {required this.customerID,
      required this.favoriteID,
      required this.productID});

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return FavoriteModel(
        customerID: data['customerID'],
        favoriteID: data['favoriteID'],
        productID: data['productID']);
  }

  Map<String, dynamic> toFirestore() => {
        'customerID': customerID,
        'favoriteID': favoriteID,
        'productID': productID
      };
}

// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final cartID;
  final customerID;
  final productIDs;
  final vendorID;

  CartModel({
    required this.cartID,
    required this.customerID,
    required this.productIDs,
    required this.vendorID,
  });

  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return CartModel(
      cartID: data['cartID'],
      customerID: data['customerID'],
      productIDs: data['productIDs'],
      vendorID: data['vendorID'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'cartID': cartID,
        'customerID': customerID,
        'productIDs': productIDs,
        'vendorID': vendorID,
      };
}

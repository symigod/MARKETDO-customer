// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final cartID;
  final customerID;

  final payments;
  final productIDs;
  final unitsBought;
  final vendorID;

  CartModel({
    required this.cartID,
    required this.customerID,
    required this.payments,
    required this.productIDs,
    required this.unitsBought,
    required this.vendorID,
  });

  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return CartModel(
      cartID: data['cartID'],
      customerID: data['customerID'],
      payments: data['payments'],
      productIDs: data['productIDs'],
      unitsBought: data['unitsBought'],
      vendorID: data['vendorID'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'cartID': cartID,
        'customerID': customerID,
        'payments': payments,
        'productIDs': productIDs,
        'unitsBought': unitsBought,
        'vendorID': vendorID,
      };
}

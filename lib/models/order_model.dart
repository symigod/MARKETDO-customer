// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final customerID;
  final orderID;
  final orderStatus;
  final paymentMethod;
  final productIDs;
  final shippingFee;
  final shippingMethod;
  final orderedOn;
  final totalPayment;
  final vendorID;

  OrderModel({
    required this.customerID,
    required this.orderID,
    required this.orderStatus,
    required this.paymentMethod,
    required this.productIDs,
    required this.shippingFee,
    required this.shippingMethod,
    required this.orderedOn,
    required this.totalPayment,
    required this.vendorID,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return OrderModel(
      customerID: data['customerID'],
      orderID: data['orderID'],
      orderStatus: data['orderStatus'],
      paymentMethod: data['paymentMethod'],
      productIDs: data['productIDs'],
      shippingFee: data['shippingFee'],
      shippingMethod: data['shippingMethod'],
      orderedOn: data['orderedOn'],
      totalPayment: data['totalPayment'],
      vendorID: data['vendorID'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'customerID': customerID,
        'orderID': orderID,
        'orderStatus': orderStatus,
        'paymentMethod': paymentMethod,
        'productIDs': productIDs,
        'shippingFee': shippingFee,
        'shippingMethod': shippingMethod,
        'orderedOn': orderedOn,
        'totalPayment': totalPayment,
        'vendorID': vendorID,
      };
}

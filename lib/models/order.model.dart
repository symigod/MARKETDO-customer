// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final attachment;
  final customerID;
  final isPending;
  final orderID;
  final payments;
  final paymentMethod;
  final productIDs;
  final shippingFee;
  final shippingMethod;
  final orderedOn;
  final totalPayment;
  final unitsBought;
  final vendorID;

  OrderModel({
    required this.attachment,
    required this.customerID,
    required this.isPending,
    required this.orderID,
    required this.payments,
    required this.paymentMethod,
    required this.productIDs,
    required this.shippingFee,
    required this.shippingMethod,
    required this.orderedOn,
    required this.totalPayment,
    required this.unitsBought,
    required this.vendorID,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return OrderModel(
      attachment: data['attachment'],
      customerID: data['customerID'],
      isPending: data['isPending'],
      orderID: data['orderID'],
      payments: data['payments'],
      paymentMethod: data['paymentMethod'],
      productIDs: data['productIDs'],
      shippingFee: data['shippingFee'],
      shippingMethod: data['shippingMethod'],
      orderedOn: data['orderedOn'],
      totalPayment: data['totalPayment'],
      unitsBought: data['unitsBought'],
      vendorID: data['vendorID'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'attachment': attachment,
        'customerID': customerID,
        'isPending': isPending,
        'orderID': orderID,
        'payments': payments,
        'paymentMethod': paymentMethod,
        'productIDs': productIDs,
        'shippingFee': shippingFee,
        'shippingMethod': shippingMethod,
        'orderedOn': orderedOn,
        'totalPayment': totalPayment,
        'unitsBought': unitsBought,
        'vendorID': vendorID,
      };
}

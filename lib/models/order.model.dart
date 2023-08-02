// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final attachment;
  final customerID;
  final isDelivered;
  final orderID;
  final payments;
  final paymentMethod;
  final productIDs;
  final deliveryFee;
  final deliveryMethod;
  final orderedOn;
  final totalPayment;
  final unitsBought;
  final vendorID;

  OrderModel({
    required this.attachment,
    required this.customerID,
    required this.isDelivered,
    required this.orderID,
    required this.payments,
    required this.paymentMethod,
    required this.productIDs,
    required this.deliveryFee,
    required this.deliveryMethod,
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
      isDelivered: data['isDelivered'],
      orderID: data['orderID'],
      payments: data['payments'],
      paymentMethod: data['paymentMethod'],
      productIDs: data['productIDs'],
      deliveryFee: data['deliveryFee'],
      deliveryMethod: data['deliveryMethod'],
      orderedOn: data['orderedOn'],
      totalPayment: data['totalPayment'],
      unitsBought: data['unitsBought'],
      vendorID: data['vendorID'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'attachment': attachment,
        'customerID': customerID,
        'isDelivered': isDelivered,
        'orderID': orderID,
        'payments': payments,
        'paymentMethod': paymentMethod,
        'productIDs': productIDs,
        'deliveryFee': deliveryFee,
        'deliveryMethod': deliveryMethod,
        'orderedOn': orderedOn,
        'totalPayment': totalPayment,
        'unitsBought': unitsBought,
        'vendorID': vendorID,
      };
}

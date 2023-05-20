import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final address;
  final customerName;
  final email;
  final landMark;
  final mobile;
  final orderStatus;
  final paymentMethod;
  final products;
  final shippingFee;
  final shippingMethod;
  final status;
  final time;
  final totalAmount;
  final totalPrice;
  final uid;
  final vendorName;

  Order({
    required this.address,
    required this.customerName,
    required this.email,
    required this.landMark,
    required this.mobile,
    required this.orderStatus,
    required this.paymentMethod,
    required this.products,
    required this.shippingFee,
    required this.shippingMethod,
    required this.status,
    required this.time,
    required this.totalAmount,
    required this.totalPrice,
    required this.uid,
    required this.vendorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'customerName': customerName,
      'email': email,
      'landMark': landMark,
      'mobile': mobile,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'products': products,
      'shippingFee': shippingFee,
      'shippingMethod': shippingMethod,
      'status': status,
      'time': time,
      'totalAmount': totalAmount,
      'totalPrice': totalPrice,
      'uid': uid,
      'vendorName': vendorName,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      address: map['address'],
      customerName: map['customerName'],
      email: map['email'],
      landMark: map['landMark'],
      mobile: map['mobile'],
      orderStatus: map['orderStatus'],
      paymentMethod: map['paymentMethod'],
      products: map['products'],
      shippingFee: map['shippingFee'],
      shippingMethod: map['shippingMethod'],
      status: map['status'],
      time: map['time'],
      totalAmount: map['totalAmount'],
      totalPrice: map['totalPrice'],
      uid: map['uid'],
      vendorName: map['vendorName'],
    );
  }
}

Stream<List<Order>> orderQuery() {
  return FirebaseFirestore.instance.collection('orders').snapshots().map(
      (order) => order.docs.map((doc) => Order.fromMap(doc.data())).toList());
}

Stream<List<Order>> getSingleOrder(Timestamp time) {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('time', isEqualTo: time)
      .snapshots()
      .map((order) =>
          order.docs.map((doc) => Order.fromMap(doc.data())).toList());
}

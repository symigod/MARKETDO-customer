// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final address;
  final coverPhoto;
  final customerID;
  final email;
  final isApproved;
  final landMark;
  final logo;
  final mobile;
  final name;
  final registeredOn;

  CustomerModel({
    required this.address,
    required this.coverPhoto,
    required this.customerID,
    required this.email,
    required this.isApproved,
    required this.landMark,
    required this.logo,
    required this.mobile,
    required this.name,
    required this.registeredOn,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return CustomerModel(
      address: data['address'],
      coverPhoto: data['coverPhoto'],
      customerID: data['customerID'],
      email: data['email'],
      isApproved: data['isApproved'],
      landMark: data['landMark'],
      logo: data['logo'],
      mobile: data['mobile'],
      name: data['name'],
      registeredOn: data['registeredOn'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'address': address,
        'coverPhoto': coverPhoto,
        'customerID': customerID,
        'email': email,
        'isApproved': isApproved,
        'landMark': landMark,
        'logo': logo,
        'mobile': mobile,
        'name': name,
        'registeredOn': registeredOn,
      };
}

// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final address;
  final businessName;
  final email;
  final isActive;
  final isApproved;
  final isTaxRegistered;
  final landMark;
  final logo;
  final mobile;
  final shopImage;
  final registeredOn;
  final vendorID;

  VendorModel({
    required this.address,
    required this.businessName,
    required this.email,
    required this.isActive,
    required this.isApproved,
    required this.isTaxRegistered,
    required this.landMark,
    required this.logo,
    required this.mobile,
    required this.shopImage,
    required this.registeredOn,
    required this.vendorID,
  });

  factory VendorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return VendorModel(
      address: data['address'],
      businessName: data['businessName'],
      email: data['email'],
      isActive: data['isActive'],
      isApproved: data['isApproved'],
      isTaxRegistered: data['isTaxRegistered'],
      landMark: data['landMark'],
      logo: data['logo'],
      mobile: data['mobile'],
      shopImage: data['shopImage'],
      registeredOn: data['registeredOn'],
      vendorID: data['vendorID'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'address': address,
        'businessName': businessName,
        'email': email,
        'isActive': isActive,
        'isApproved': isApproved,
        'isTaxRegistered': isTaxRegistered,
        'landMark': landMark,
        'logo': logo,
        'mobile': mobile,
        'shopImage': shopImage,
        'registeredOn': registeredOn,
        'vendorID': vendorID,
      };
}

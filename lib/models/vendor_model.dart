// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final businessName;
  final city;
  final country;
  final email;
  final isActive;
  final isApproved;
  final isTaxRegistered;
  final landMark;
  final logo;
  final mobile;
  final pinCode;
  final shopImage;
  final state;
  final registeredOn;
  final tin;
  final vendorID;

  VendorModel({
    required this.businessName,
    required this.city,
    required this.country,
    required this.email,
    required this.isActive,
    required this.isApproved,
    required this.isTaxRegistered,
    required this.landMark,
    required this.logo,
    required this.mobile,
    required this.pinCode,
    required this.shopImage,
    required this.state,
    required this.registeredOn,
    required this.tin,
    required this.vendorID,
  });

  factory VendorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return VendorModel(
      businessName: data['businessName'],
      city: data['city'],
      country: data['country'],
      email: data['email'],
      isActive: data['isActive'],
      isApproved: data['isApproved'],
      isTaxRegistered: data['isTaxRegistered'],
      landMark: data['landMark'],
      logo: data['logo'],
      mobile: data['mobile'],
      pinCode: data['pinCode'],
      shopImage: data['shopImage'],
      state: data['state'],
      registeredOn: data['registeredOn'],
      tin: data['tin'],
      vendorID: data['vendorID'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'businessName': businessName,
        'city': city,
        'country': country,
        'email': email,
        'isActive': isActive,
        'isApproved': isApproved,
        'isTaxRegistered': isTaxRegistered,
        'landMark': landMark,
        'logo': logo,
        'mobile': mobile,
        'pinCode': pinCode,
        'shopImage': shopImage,
        'state': state,
        'registeredOn': registeredOn,
        'tin': tin,
        'vendorID': vendorID,
      };
}

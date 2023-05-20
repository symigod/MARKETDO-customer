import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {

  Vendor({
    this.approved,
    this.businessName,
    this.city,
    this.state,
    this.country,
    this.email,
    this.landMark,
    this.logo,
    this.shopImage,
    this.mobile,
    this.pinCode,
    this.taxRegistered,
    this.time,
    this.tinNumber,
  this.uid});


  Vendor.fromJson(Map<String, Object?> json)
  : this (
  approved: json['approved']! as bool,
  businessName:json['businessName']! as String,
  city: json['city']! as String,
  state:json['state']! as String,
  country: json['country']! as String,
  email: json['email']! as String,
  landMark: json['landMark']! as String,
  logo: json['logo']! as String,
  shopImage: json['shopImage']! as String,
  mobile: json['mobile']! as String,
  pinCode: json['pinCode']! as String,
  taxRegistered: json['taxRegistered']! as String,
  time: json['time']! as Timestamp,
  tinNumber: json['tinNumber']! as String,
  uid: json['uid']! as String,

  );

  final bool? approved;
    final String? businessName;
  final String? city;
  final String? state;
  final String? country;
  final String? email;
  final String? landMark;
  final String? logo;
  final String? shopImage;
  final String? mobile;
  final String? pinCode;
  final String? taxRegistered;
  final Timestamp? time;
  final String? tinNumber;
  final String? uid;

  Map<String, Object?> toJson() {
    return {

      'approved': approved,
      'businessName': businessName,
      'city': city,
      'state': state,
      'country': country,
      'email': email,
      'landMark': landMark,
      'logo': logo,
      'shopImage': shopImage,
      'mobile': mobile,
      'pinCode': pinCode,
      'taxRegistered': taxRegistered,
      'time': time,
      'tinNumber': tinNumber,
      'uid': uid
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {

  Customer({
    this.approved,
    this.customerName,
    this.address,
    this.email,
    this.landMark,
    this.logo,
    this.cusImage,
    this.mobile,
    this.time,
    this.uid});

  Customer.fromJson(Map<String, Object?> json)
      : this(
    approved: json['approved']! as bool,
    customerName: json['customerName']! as String,
    address: json['address']! as String,
    email: json['email']! as String,
    landMark: json['landMark']! as String,
    logo: json['logo']! as String,
    mobile: json['mobile']! as String,
    cusImage: json['cusImage']! as String,
    time: json['time']! as Timestamp,
    uid: json['uid']! as String,

  );

  final bool? approved;
  final String? customerName;
  final String? address;
  final String? email;
  final String? landMark;
  final String? logo;
  final String? cusImage;
  final String? mobile;
  final Timestamp? time;
  final String? uid;

  Map<String, Object?> toJson() {
    return {
      'approved': approved,
      'customerName': customerName,
      'address': address,
      'email': email,
      'landMark': landMark,
      'logo': logo,
      'cusImage': cusImage,
      'mobile': mobile,
      'time': time,
      'uid': uid
    };
  }
}

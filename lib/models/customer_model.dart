import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String address;
  final bool approved;
  final String coverPhoto;
  final String email;
  final String landMark;
  final String logo;
  final String mobile;
  final String name;
  final Timestamp time;

  Customer(
      {required this.address,
      required this.approved,
      required this.coverPhoto,
      required this.email,
      required this.landMark,
      required this.logo,
      required this.mobile,
      required this.name,
      required this.time});

  Customer.fromJson(Map<String, Object?> json)
      : this(
            address: json['address']! as String,
            approved: json['approved']! as bool,
            coverPhoto: json['coverPhoto']! as String,
            email: json['email']! as String,
            landMark: json['landMark']! as String,
            logo: json['logo']! as String,
            mobile: json['mobile']! as String,
            name: json['name']! as String,
            time: json['time']! as Timestamp);

  Map<String, Object?> toJson() {
    return {
      'address': address,
      'approved': approved,
      'coverPhoto': coverPhoto,
      'email': email,
      'landMark': landMark,
      'logo': logo,
      'mobile': mobile,
      'name': name,
      'time': time
    };
  }
}

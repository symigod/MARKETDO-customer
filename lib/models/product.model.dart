// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final category;
  final description;
  final imageURL;
  final isInventoryManaged;
  final isShipCharged;
  final productID;
  final productName;
  final regularPrice;
  final shippingCharge;
  final stockOnHand;
  final subcategory;
  final unit;
  final vendorID;

  ProductModel({
    required this.category,
    required this.description,
    required this.imageURL,
    required this.isInventoryManaged,
    required this.isShipCharged,
    required this.productID,
    required this.productName,
    required this.regularPrice,
    required this.shippingCharge,
    required this.stockOnHand,
    required this.subcategory,
    required this.unit,
    required this.vendorID,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return ProductModel(
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageURL: data['imageURL'] ?? '',
      isInventoryManaged: data['isInventoryManaged'] ?? false,
      isShipCharged: data['isShipCharged'] ?? false,
      productID: data['productID'],
      productName: data['productName'] ?? '',
      regularPrice: data['regularPrice'] ?? 0.0,
      shippingCharge: data['shippingCharge'] ?? 0.0,
      stockOnHand: data['stockOnHand'] ?? 0.0,
      subcategory: data['subcategory'] ?? '',
      unit: data['unit'] ?? '',
      vendorID: data['vendorID'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'category': category,
        'description': description,
        'imageURL': imageURL,
        'isInventoryManaged': isInventoryManaged,
        'isShipCharged': isShipCharged,
        'productID': productID,
        'productName': productName,
        'regularPrice': regularPrice,
        'shippingCharge': shippingCharge,
        'stockOnHand': stockOnHand,
        'subcategory': subcategory,
        'unit': unit,
        'vendorID': vendorID,
      };
}

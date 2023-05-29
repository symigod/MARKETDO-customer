// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final brand;
  final category;
  final isShipCharged;
  final description;
  final imageURL;
  final isApproved;
  final mainCategory;
  final isInventoryManaged;
  final otherDetails;
  final productID;
  final productName;
  final regularPrice;
  final vendorID;
  final shippingCharge;
  final size;
  final stockOnHand;
  final unit;

  ProductModel({
    required this.brand,
    required this.category,
    required this.isShipCharged,
    required this.description,
    required this.imageURL,
    required this.isApproved,
    required this.mainCategory,
    required this.isInventoryManaged,
    required this.otherDetails,
    required this.productID,
    required this.productName,
    required this.regularPrice,
    required this.vendorID,
    required this.shippingCharge,
    required this.size,
    required this.stockOnHand,
    required this.unit,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return ProductModel(
        brand: data['brand'] ?? '',
        category: data['category'] ?? '',
        isShipCharged: data['isShipCharged'] ?? false,
        description: data['description'] ?? '',
        imageURL: data['imageURL'] ?? '',
        isApproved: data['isApproved'] ?? false,
        mainCategory: data['mainCategory'] ?? '',
        isInventoryManaged: data['isInventoryManaged'] ?? false,
        otherDetails: data['otherDetails'] ?? '',
        productID: data['productID'],
        productName: data['productName'] ?? '',
        regularPrice: data['regularPrice'] ?? 0.0,
        vendorID: data['vendorID'] ?? '',
        shippingCharge: data['shippingCharge'] ?? 0.0,
        size: data['size'] ?? 0.0,
        stockOnHand: data['stockOnHand'] ?? 0.0,
        unit: data['unit'] ?? '');
  }

  Map<String, dynamic> toFirestore() => {
        'brand': brand,
        'category': category,
        'isShipCharged': isShipCharged,
        'description': description,
        'imageURL': imageURL,
        'isApproved': isApproved,
        'mainCategory': mainCategory,
        'isInventoryManaged': isInventoryManaged,
        'otherDetails': otherDetails,
        'productID': productID,
        'productName': productName,
        'regularPrice': regularPrice,
        'vendorID': vendorID,
        'shippingCharge': shippingCharge,
        'size': size,
        'stockOnHand': stockOnHand,
        'unit': unit,
      };
}

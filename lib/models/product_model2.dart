import 'package:cloud_firestore/cloud_firestore.dart';

class Product2 {
  final approved;
  final brand;
  final category;
  final chargeShipping;
  final description;
  final imageUrls;
  final mainCategory;
  final manageInventory;
  final otherDetails;
  final productID;
  final productName;
  final regularPrice;
  final seller;
  final shippingCharge;
  final size;
  final soh;
  final unit;

  Product2({
    required this.approved,
    required this.brand,
    required this.category,
    required this.chargeShipping,
    required this.description,
    required this.imageUrls,
    required this.mainCategory,
    required this.manageInventory,
    required this.otherDetails,
    required this.productID,
    required this.productName,
    required this.regularPrice,
    required this.seller,
    required this.shippingCharge,
    required this.size,
    required this.soh,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'approved': approved,
      'brand': brand,
      'category': category,
      'chargeShipping': chargeShipping,
      'description': description,
      'imageUrls': imageUrls,
      'mainCategory': mainCategory,
      'manageInventory': manageInventory,
      'otherDetails': otherDetails,
      'productID': productID,
      'productName': productName,
      'regularPrice': regularPrice,
      'seller': seller,
      'shippingCharge': shippingCharge,
      'size': size,
      'soh': soh,
      'unit': unit,
    };
  }

  factory Product2.fromMap(Map<String, dynamic> map) {
    return Product2(
      approved: map['approved'],
      brand: map['brand'],
      category: map['category'],
      chargeShipping: map['chargeShipping'],
      description: map['description'],
      imageUrls: map['imageUrls'],
      mainCategory: map['mainCategory'],
      manageInventory: map['manageInventory'],
      otherDetails: map['otherDetails'],
      productID: map['productID'],
      productName: map['productName'],
      regularPrice: map['regularPrice'],
      seller: map['seller'],
      shippingCharge: map['shippingCharge'],
      size: map['size'],
      soh: map['soh'],
      unit: map['unit'],
    );
  }
}

Stream<List<Product2>> searchProduct(String searchText) {
  return FirebaseFirestore.instance
      .collection('products')
      .where('productName', isEqualTo: searchText)
      .where('productName', isGreaterThanOrEqualTo: searchText)
      .where('productName', isLessThan: '${searchText}z')
      .snapshots()
      .map((product) =>
          product.docs.map((doc) => Product2.fromMap(doc.data())).toList());
}

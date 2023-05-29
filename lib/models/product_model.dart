import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productID;
  final String? productName;
  final double? regularPrice;
  final String? category;
  final String? mainCategory;
  final String? description;
  final bool? manageInventory;
  final double? soh;
  final bool? chargeShipping;
  final double? shippingCharge;
  final String? brand;
  final List? size;
  final String? otherDetails;
  final String? unit;
  final List? imageUrls;
  final Map? seller;
  final bool? approved;
  Product(
      {required this.productID,
      this.productName,
      this.regularPrice,
      this.category,
      this.mainCategory,
      this.description,
      this.manageInventory,
      this.soh,
      this.chargeShipping,
      this.shippingCharge,
      this.brand,
      this.size,
      this.otherDetails,
      this.unit,
      this.imageUrls,
      this.seller,
      this.approved});

  Map<String, Object?> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'regularPrice': regularPrice,
      'category': category,
      'mainCategory': mainCategory,
      'description': description,
      'manageInventory': manageInventory,
      'soh': soh,
      'chargeShipping': chargeShipping,
      'shippingCharge': shippingCharge,
      'brand': brand,
      'size': size,
      'otherDetails': otherDetails,
      'unit': unit,
      'imageUrls': imageUrls,
      'seller': seller,
      'approved': approved,
    };
  }

  Product.fromJson(Map<String, Object?> json)
      : this(
          productID: json['productID']! as String,
          productName: json['productName']! as String,
          regularPrice: json['regularPrice']! as double,
          category: json['category']! as String,
          mainCategory: json['mainCategory'] == null
              ? null
              : json['mainCategory']! as String,
          description: json['description'] == null
              ? null
              : json['description']! as String,
          manageInventory: json['manageInventory'] == null
              ? null
              : json['manageInventory']! as bool,
          soh: json['soh'] == null ? null : json['soh']! as double,
          chargeShipping: json['chargeShipping'] == null
              ? null
              : json['chargeShipping']! as bool,
          shippingCharge: json['shippingCharge'] == null
              ? null
              : json['shippingCharge']! as double,
          brand: json['brand'] == null ? null : json['brand']! as String,
          size: json['size'] == null ? null : json['size']! as List,
          otherDetails: json['otherDetails'] == null
              ? null
              : json['otherDetails']! as String,
          unit: json['unit'] == null ? null : json['unit']! as String,
          imageUrls: json['imageUrls']! as List,
          seller: json['seller']! as Map,
          approved: json['approved']! as bool,
        );
}

productQuery({category}) => FirebaseFirestore.instance
    .collection('product')
    .where('approved', isEqualTo: true)
    .where('category', isEqualTo: category)
    .withConverter<Product>(
      fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
      toFirestore: (product, _) => product.toJson(),
    );

searchQuery({searchText}) => FirebaseFirestore.instance
        .collection('product')
        .orderBy('productName')
        .startAt([searchText.toUpperCase()]).endAt(
            ['${searchText.toUpperCase()}\uf8ff']).withConverter<Product>(
      fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
      toFirestore: (product, _) => product.toJson(),
    );

class CartModel {
  final String id;
  final List imageUrls;
  final String productName;
  final double regularPrice;
  final String sellerName;

  CartModel(
      {required this.id,
      required this.imageUrls,
      required this.productName,
      required this.regularPrice,
      required this.sellerName});

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrls': imageUrls,
        'productName': productName,
        'regularPrice': regularPrice,
        'sellerName': sellerName
      };

  static CartModel fromJson(Map<String, dynamic> json) => CartModel(
      id: json['id'],
      imageUrls: json['imageUrls'],
      productName: json['productName'],
      regularPrice: json['regularPrice'],
      sellerName: json['sellerName']);
}

// kini ra nga format sa MODEL gamita
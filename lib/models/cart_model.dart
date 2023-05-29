class CartModel {
  final String customerID;
  final String productID;
  final String vendorID;
  // final String cartID;
  // final List imageUrls;
  // final double regularPrice;
  // final String sellerName;

  CartModel({
    required this.customerID,
    required this.productID,
    required this.vendorID,
    // required this.cartID,
    // required this.imageUrls,

    // required this.regularPrice,
    // required this.sellerName
  });

  Map<String, dynamic> toJson() => {
        'customerID': customerID,
        'productID': productID,
        'vendorID': vendorID,
        // 'cartID': cartID,
        // 'imageUrls': imageUrls,
        // 'regularPrice': regularPrice,
        // 'sellerName': sellerName
      };

  static CartModel fromJson(Map<String, dynamic> json) => CartModel(
        customerID: json['customerID'],
        productID: json['productID'],
        vendorID: json['vendorID'],
        // cartID: json['cartID'],
        // imageUrls: json['imageUrls'],
        // regularPrice: json['regularPrice'],
        // sellerName: json['sellerName']
      );
}

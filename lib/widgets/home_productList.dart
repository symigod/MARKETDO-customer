import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:marketdo_app/models/product_model.dart';
import 'package:marketdo_app/screens/product_details_screen.dart';

class HomeProductList extends StatelessWidget {
  final String? category;
  const HomeProductList({this.category, super.key});

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.grey.shade200,
      child: FirestoreQueryBuilder<Product>(
          query: productQuery(category: category),
          builder: (context, snapshot, _) {
            return GridView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 1 / 1.4),
                itemCount: snapshot.docs.length,
                itemBuilder: (context, index) {
                  if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                    snapshot.fetchMore();
                  }
                  var productIndex = snapshot.docs[index];
                  Product product = productIndex.data();
                  String productID = productIndex.id;
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 500),
                                  pageBuilder: (context, __, ___) =>
                                      ProductDetailScreen(
                                          productId: productID,
                                          product: product))),
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              height: 80,
                              width: 80,
                              child: Column(children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: SizedBox(
                                        height: 90,
                                        width: 90,
                                        child: Hero(
                                            tag: product.imageUrls![0],
                                            child: CachedNetworkImage(
                                              imageUrl: product.imageUrls![0],
                                              fit: BoxFit.cover,
                                            )))),
                                const SizedBox(height: 10),
                                Text('${product.productName}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 2)
                              ]))));
                });
          }));
}

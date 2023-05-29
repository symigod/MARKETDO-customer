import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:marketdo_app/models/product_model.dart';
import 'package:marketdo_app/screens/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchText;
  const SearchScreen({super.key, required this.searchText});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: FittedBox(
                child: Text('Search results for "${widget.searchText}"'))),
        body: FirestoreQueryBuilder<Product>(
            query: searchQuery(searchText: widget.searchText),
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
                        padding: const EdgeInsets.all(10),
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
                                                  imageUrl:
                                                      product.imageUrls![0],
                                                  fit: BoxFit.cover)))),
                                  const SizedBox(height: 10),
                                  Text('${product.productName}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 2)
                                ]))));
                  });
            }));
  }
}

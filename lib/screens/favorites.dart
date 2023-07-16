import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/screens/products/details.product.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0, toolbarHeight: 0),
        body: StreamBuilder(
            stream: favoritesCollection
                .where('favoriteOf', isEqualTo: authID)
                .snapshots(),
            builder: (context, fs) {
              if (fs.hasError) {
                return errorWidget(fs.error.toString());
              }
              if (fs.connectionState == ConnectionState.waiting) {
                return loadingWidget();
              }
              if (fs.data!.docs.isNotEmpty) {
                final favorites = fs.data!.docs;
                return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = favorites[index];
                      return FutureBuilder(
                          future: productsCollection
                              .where('productID',
                                  whereIn: favorite['productIDs'])
                              .get(),
                          builder: (context, ps) {
                            if (ps.hasError) {
                              return errorWidget(ps.error.toString());
                            }
                            if (ps.connectionState == ConnectionState.waiting) {
                              return loadingWidget();
                            }
                            if (ps.data!.docs.isNotEmpty) {
                              final products = ps.data!.docs;
                              return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return ListTile(
                                        dense: true,
                                        isThreeLine: true,
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ProductDetailScreen(
                                                        productID:
                                                            product[
                                                                'productID']))),
                                        leading: SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: CachedNetworkImage(
                                                    imageUrl:
                                                        product['imageURL'],
                                                    fit: BoxFit.cover))),
                                        title: Text(product['productName'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(product['description']),
                                        trailing: Text(
                                            'P ${numberToString(product['regularPrice'].toDouble())} per ${product['unit']}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)));
                                  });
                            }
                            return emptyWidget('PRODUCT NOT FOUND');
                          });
                    });
              }
              return emptyWidget('NO FAVORITES YET');
            }));
  }
}

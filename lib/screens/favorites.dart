import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/screens/products/details.product.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0, toolbarHeight: 0),
        body: StreamBuilder(
            stream: favoritesCollection
                .where('customerID', isEqualTo: authID)
                .snapshots(),
            builder: (context, fs) {
              if (fs.hasError) {
                return errorWidget(fs.error.toString());
              }
              if (fs.connectionState == ConnectionState.waiting) {
                return loadingWidget();
              }
              if (fs.data!.docs.isNotEmpty) {
                final favorite = fs.data!.docs;
                return ListView.builder(
                    itemCount: favorite.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                          future: productsCollection
                              .where('productID',
                                  isEqualTo: favorite[index]['productID'])
                              .get(),
                          builder: (context, ps) {
                            if (ps.hasError) {
                              return errorWidget(ps.error.toString());
                            }
                            if (ps.connectionState == ConnectionState.waiting) {
                              return loadingWidget();
                            }
                            if (ps.data!.docs.isNotEmpty) {
                              final product = ps.data!.docs[0];
                              return ListTile(
                                  dense: true,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                              productID:
                                                  product['productID']))),
                                  leading: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: CachedNetworkImage(
                                              imageUrl: product['imageURL'],
                                              fit: BoxFit.cover))),
                                  title: Text(product['productName'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'P ${product['regularPrice'].toDouble().toStringAsFixed(2)}',
                                      style:
                                          const TextStyle(color: Colors.red)),
                                  trailing: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: FutureBuilder(
                                              future: vendorsCollection
                                                  .where('vendorID',
                                                      isEqualTo:
                                                          product['vendorID'])
                                                  .get(),
                                              builder: (context, vs) {
                                                if (vs.hasError) {
                                                  return errorWidget(
                                                      ps.error.toString());
                                                }
                                                if (vs.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return loadingWidget();
                                                }
                                                if (vs.data!.docs.isNotEmpty) {
                                                  final vendor =
                                                      vs.data!.docs[0];
                                                  return Image.network(
                                                      vendor['logo'],
                                                      fit: BoxFit.cover);
                                                }
                                                return loadingWidget();
                                              }))));
                            }
                            return emptyWidget('PRODUCT NOT FOUND');
                          });
                    });
              }
              return emptyWidget('NO FAVORITES YET');
            }));
  }
}

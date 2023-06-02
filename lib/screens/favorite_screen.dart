import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marketdo_app/screens/product_details_screen.dart';
import 'package:marketdo_app/widgets/api_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  final Stream stream;
  const FavoritesScreen({super.key, required this.stream});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('My Favorites')),
        body: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('favorites').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return errorWidget(snapshot.error.toString());
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingWidget();
              }
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return emptyWidget('NO FAVORITES YET');
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final favorite = snapshot.data!.docs[index];
                    final String imageUrls = favorite['imageUrls'];
                    final String productName = favorite['productName'];
                    final String description = favorite['description'];
                    final double regularPrice = favorite['regularPrice'];
                    return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                    productID: favorite['productID']))),
                        child: Card(
                            child: ListTile(
                                leading: CachedNetworkImage(
                                    imageUrl: imageUrls,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error)),
                                title: Text(productName),
                                subtitle: Text(description),
                                trailing: Text(
                                    'Price: \$${regularPrice.toStringAsFixed(2)}'))));
                  });
            }));
  }
}

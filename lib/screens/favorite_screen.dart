import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marketdo_app/screens/product_details_screen.dart';

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
            stream: widget.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('NO FAVORITES YET'));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final DocumentSnapshot document =
                        snapshot.data!.docs[index];
                    final String imageUrls = document['imageUrls'];
                    final String productName = document['productName'];
                    final String description = document['description'];
                    final double regularPrice = document['regularPrice'];
                    return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                    productId: document['productID']))),
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

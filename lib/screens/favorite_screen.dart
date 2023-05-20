import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marketdo_app/screens/product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('favorites').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No favorites found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];
              final String imageUrls = document['imageUrls'];
              final String productName = document['productName'];
              final String description = document['description'];
              final double regularPrice = document['regularPrice'];

              return GestureDetector(
                onTap: () {
                  // Handle the tap event here, e.g., navigate to product details screen
                  // Pass the necessary data to the details screen using arguments
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductDetailScreen(),
                    ),
                  );
                },
                child: Card(
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: imageUrls,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    title: Text(productName),
                    subtitle: Text(description),
                    trailing:
                        Text('Price: \$${regularPrice.toStringAsFixed(2)}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

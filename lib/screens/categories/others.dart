import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/models/product.model.dart';
import 'package:marketdo_app/screens/products/details.product.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class Others extends StatefulWidget {
  const Others({super.key});

  @override
  State<Others> createState() => _OthersState();
}

class _OthersState extends State<Others> {
  @override
  Widget build(BuildContext context) => ListView(children: [
        StreamBuilder(
            stream: productsCollection
                .where('category', isEqualTo: 'Others')
                .orderBy('productName')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return errorWidget(snapshot.error.toString());
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingWidget();
              }
              return GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 1 / 1.4),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    List<ProductModel> productModel = snapshot.data!.docs
                        .map((doc) => ProductModel.fromFirestore(doc))
                        .toList();
                    var product = productModel[index];
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                        productID: product.productID))),
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
                                          child: CachedNetworkImage(
                                              imageUrl: product.imageURL,
                                              fit: BoxFit.cover))),
                                  const SizedBox(height: 5),
                                  Text(product.productName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 2)
                                ]))));
                  });
            })
      ]);
}

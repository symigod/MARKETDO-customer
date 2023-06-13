import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? selectedCategories;

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: categoriesCollection.orderBy('category').snapshots(),
      builder: (context, cs) {
        if (cs.hasError) {
          return errorWidget(cs.error.toString());
        }
        if (cs.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (cs.hasData) {
          var categories = cs.data!.docs;
          return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                List<String> subcategories =
                    List<String>.from(category['subcategories']);
                subcategories
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                return ExpansionTile(
                    leading: SizedBox(
                        height: 40,
                        width: 40,
                        child: ClipRRect(
                            child: CachedNetworkImage(
                                imageUrl: category['imageURL'],
                                fit: BoxFit.cover))),
                    title: Text(category['category']),
                    childrenPadding: const EdgeInsets.all(5),
                    children: [
                      Wrap(
                          spacing: 3,
                          children: subcategories
                              .map((e) => Chip(
                                  backgroundColor: Colors.greenAccent,
                                  label: Text(e)))
                              .toList())
                    ]);
              });
        }
        return emptyWidget('NO CATEGORIES FOUND');
      });
}

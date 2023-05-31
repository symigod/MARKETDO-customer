import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:marketdo_app/models/category_model.dart';
import 'package:marketdo_app/widgets/category/main_category_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _title = 'Categories';
  String? selectedCategories;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(selectedCategories == null ? _title : selectedCategories!,
              style: TextStyle(color: Colors.green.shade800)),
          iconTheme: const IconThemeData(color: Colors.black54),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            // IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})
          ]),
      body: Row(children: [
        SizedBox(
            width: 80,
            // color: Colors.grey.shade300,
            child: FirestoreListView<Category>(
                query: categoryCollection,
                itemBuilder: (context, snapshot) {
                  Category category = snapshot.data();
                  return InkWell(
                      onTap: () => setState(() {
                            _title = category.catName!;
                            selectedCategories = category.catName;
                          }),
                      child: SizedBox(
                          height: 70,
                          // color: selectedCategories == category.catName
                          //     ? Colors.white
                          //     : Colors.grey.shade300,
                          child: Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                            height: 30,
                                            child: CachedNetworkImage(
                                                imageUrl: category.image!,
                                                color: selectedCategories ==
                                                        category.catName
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.grey.shade700)),
                                        Text(category.catName!,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: selectedCategories ==
                                                        category.catName
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.grey.shade700),
                                            textAlign: TextAlign.center)
                                      ])))));
                })),
        MainCategoryWidget(selectedCat: selectedCategories)
      ]));
}

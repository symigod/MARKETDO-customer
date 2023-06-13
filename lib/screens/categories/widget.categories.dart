import 'package:flutter/material.dart';
import 'package:marketdo_app/screens/products/list.products.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  // String? _selectedCategory;

  @override
  Widget build(BuildContext context) => const Column(children: [
        Padding(
            padding: EdgeInsets.all(10),
            child: Text('Products For You',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 20))),
        HomeProductList()
      ]);
}

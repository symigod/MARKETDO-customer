import 'package:flutter/material.dart';

class ProductBottomSheet extends StatelessWidget {
  final String productID;
  const ProductBottomSheet({super.key, required this.productID});

  @override
  Widget build(BuildContext context) {
    Widget _customContainer({String? head, String? details}) {
      return Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(head!, style: const TextStyle(color: Colors.grey)),
        Padding(
            padding: const EdgeInsets.only(left: 30, top: 6, bottom: 6),
            child: Row(children: [
              const Icon(Icons.circle, size: 10),
              const SizedBox(width: 10),
              Text(details!)
            ])),
        const SizedBox(height: 10)
      ]));
    }

    return Container(
        height: 600,
        color: Colors.white,
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: const Text('Specification',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context))
              ]),
          // Padding(
          //     padding: const EdgeInsets.all(20.0),
          //     child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           if (product!.seller != null)
          //             Center(child: Image.network(product!.seller!['logo'])),
          //           const Divider(color: Colors.grey),
          //           if (product!.seller != null)
          //             _customContainer(
          //               head: 'Sellers Name :',
          //               details: product!.seller!['name'],
          //             ),
          //           if (product!.brand != null)
          //             _customContainer(
          //               head: 'Brand :',
          //               details: product!.brand,
          //             ),
          //           if (product!.unit != null)
          //             _customContainer(head: 'Unit :', details: product!.unit),
          //           if (product!.otherDetails != null)
          //             Text(product!.otherDetails!),
          //           const SizedBox(height: 10)
          //         ]))
        ])));
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/models/product_model.dart';
import 'package:marketdo_app/models/vendor_model.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/stream_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CollectionReference cartsCollection =
      FirebaseFirestore.instance.collection('carts');
  CollectionReference vendorsCollection =
      FirebaseFirestore.instance.collection('vendor');
  CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('product');

  Stream getCarts() => cartsCollection
      .where('customerID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  Stream<List<VendorModel>> getVendor(String vendorID) => vendorsCollection
      .where('vendorID', isEqualTo: vendorID)
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => VendorModel.fromFirestore(doc)).toList());
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: StreamBuilder(
          stream: getCarts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> carts = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: carts.length,
                  itemBuilder: (BuildContext context, int index) {
                    String cartID = carts[index].id;
                    List<dynamic> productIDs = carts[index]['productIDs'];
                    String vendorID = carts[index]['vendorID'];
                    return Card(
                        margin: const EdgeInsets.all(7),
                        shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(width: 1, color: Colors.black),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(children: [
                          Card(
                              color: Colors.green.shade900,
                              margin: EdgeInsets.zero,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5))),
                              child: StreamBuilder(
                                  stream: vendorsCollection
                                      .doc(vendorID)
                                      .snapshots(),
                                  builder: (context, vendorSnapshot) {
                                    if (vendorSnapshot.hasError) {
                                      return streamErrorWidget(
                                        vendorSnapshot.error.toString(),
                                      );
                                    }
                                    if (vendorSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return streamLoadingWidget();
                                    }
                                    if (vendorSnapshot.hasData) {
                                      DocumentSnapshot vendor =
                                          vendorSnapshot.data!;
                                      return Center(
                                          child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                  vendor['businessName'],
                                                  style: const TextStyle(
                                                      color: Colors.white))));
                                    }
                                    return streamEmptyWidget(
                                        'VENDOR NOT FOUND');
                                  })),
                          FutureBuilder<List<DocumentSnapshot>>(
                              future: _fetchProducts(productIDs),
                              builder: (context, productsSnapshot) {
                                if (productsSnapshot.hasError) {
                                  return streamErrorWidget(
                                      productsSnapshot.error.toString());
                                }
                                if (productsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return streamLoadingWidget();
                                }
                                if (productsSnapshot.hasData) {
                                  List<DocumentSnapshot> products =
                                      productsSnapshot.data!;
                                  double totalPrice = 0;
                                  return Column(children: [
                                    Column(
                                        children: products.map((product) {
                                      double regularPrice =
                                          product['regularPrice'].toDouble();
                                      totalPrice += regularPrice;
                                      String formattedPrice =
                                          'P ${regularPrice.toStringAsFixed(2)}';
                                      return ListTile(
                                          leading: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: Image.network(
                                                  product['imageURL'])),
                                          title: Text(product['productName']),
                                          subtitle: Text(formattedPrice),
                                          trailing: IconButton(
                                              onPressed: () =>
                                                  deleteProductInCart(
                                                      cartID,
                                                      productIDs
                                                          .indexOf(product.id)),
                                              icon: const Icon(Icons.close,
                                                  color: Colors.red)));
                                    }).toList()),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  'TOTAL: P ${totalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextButton(
                                                  onPressed: () => showDialog(
                                                      context: context,
                                                      builder: (_) => errorDialog(
                                                          context,
                                                          'This feature will be available soon!')),
                                                  child:
                                                      const Text('Place Order'))
                                            ]))
                                  ]);
                                }
                                return streamEmptyWidget('PRODUCTS NOT FOUND');
                              })
                        ]));
                  });
            }
            return streamEmptyWidget('NOTHING IN CART');
          }));

  Future<List<DocumentSnapshot>> _fetchProducts(
      List<dynamic> productIDs) async {
    List<DocumentSnapshot> products = [];
    for (dynamic id in productIDs) {
      DocumentSnapshot snapshot = await productsCollection.doc(id).get();
      if (snapshot.exists) {
        products.add(snapshot);
      }
    }
    return products;
  }

  void deleteProductInCart(String cartID, int index) async {
    DocumentSnapshot cartSnapshot =
        await FirebaseFirestore.instance.collection('carts').doc(cartID).get();
    List<dynamic> productIDs = List<dynamic>.from(cartSnapshot['productIDs']);
    if (index >= 0 && index < productIDs.length) {
      productIDs.removeAt(index);
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(cartID)
          .update({'productIDs': productIDs}).then((value) async {
        if (productIDs.isEmpty) {
          await FirebaseFirestore.instance
              .collection('carts')
              .doc(cartID)
              .delete()
              .then((value) => showDialog(
                  context: context,
                  builder: (_) => successDialog(
                      context, 'Products in cart deleted successfully!')));
        } else {
          showDialog(
              context: context,
              builder: (_) =>
                  successDialog(context, 'Product deleted successfully!'));
        }
      });
    }
  }
}

class OrderSummaryScreen extends StatefulWidget {
  final String vendorName;
  final List<ProductModel> products;

  const OrderSummaryScreen(
      {Key? key, required this.vendorName, required this.products})
      : super(key: key);

  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String _selectedPaymentMethod = 'cash_on_delivery';
  String _selectedShippingMethod = 'home_delivery';
  // final List<DocumentSnapshot> _customers = [];

  // ignore: unused_field
  User? _currentUser;
  // ignore: unused_field
  Map<String, dynamic>? _customerData;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .get();
      setState(() {
        _currentUser = user;
        _customerData = customerDoc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.products
        .fold<double>(0.0,
            (previousValue, product) => previousValue + product.regularPrice)
        .toDouble();

    double _getShippingFee() {
      if (_selectedShippingMethod == 'home_delivery') {
        return 35.0; // Replace with the actual shipping fee for home delivery
      } else if (_selectedShippingMethod == 'pick_up') {
        return 0.0;
      } else {
        return 0.0;
      }
    }

    double shippingFee = _getShippingFee();

    double getTotalPriceWithShipping() => totalPrice + _getShippingFee();

    double getTotalAmount() => getTotalPriceWithShipping();

    return Scaffold(
        appBar: AppBar(title: const Text('Order Summary')),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('customers')
                        .where('customerID',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text('Customer Information:',
                            //     style: TextStyle(
                            //         fontSize: 20, fontWeight: FontWeight.bold)),
                            // const SizedBox(height: 8),
                            // Column(children: [
                            //   ListTile(
                            //       leading: const Icon(Icons.contact_phone),
                            //       title: Text(_customerData!['name']),
                            //       subtitle: Text(_customerData!['mobile'])),
                            //   ListTile(
                            //       leading: const Icon(Icons.location_on),
                            //       title: Text(_customerData!['address']),
                            //       subtitle: Text(_customerData!['landMark']))
                            // ]),
                            // const SizedBox(height: 16),
                            Text('Vendor: ${widget.vendorName}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Products:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.products.length,
                                itemBuilder: (context, index) => ListTile(
                                    // title: Text(widget.products[index].name),
                                    subtitle: Text(
                                        '₱${widget.products[index].regularPrice}',
                                        style: const TextStyle(
                                            fontFamily: 'Roboto')))),
                            const SizedBox(height: 16),
                            const Text('Payment Method:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                                value: _selectedPaymentMethod,
                                onChanged: (value) => setState(
                                    () => _selectedPaymentMethod = value!),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'cash_on_delivery',
                                      child: Text('Cash on Delivery')),
                                  DropdownMenuItem(
                                      value: 'gcash', child: Text('Gcash'))
                                ]),
                            const SizedBox(height: 16),
                            const Text('Shipping Method:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                                value: _selectedShippingMethod,
                                onChanged: (value) => setState(
                                    () => _selectedShippingMethod = value!),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'home_delivery',
                                      child: Text('Home Delivery')),
                                  DropdownMenuItem(
                                      value: 'pick_up', child: Text('Pick-Up'))
                                ]),
                            const SizedBox(height: 16),
                            Text(
                                'Total Price: ₱${getTotalPriceWithShipping().toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text(
                                'Shipping Fee: ₱${shippingFee.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text(
                                'Total Amount: ₱${getTotalAmount().toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                                onPressed: () async {
                                  final orderData = {
                                    'customerID':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'orderStatus': 'Accepted',
                                    'paymentMethod': _selectedPaymentMethod,
                                    // 'products': widget.products
                                    //     .map((product) => product.toMap())
                                    //     .toList(),
                                    'shippingFee': 20,
                                    'shippingMethod': _selectedShippingMethod,
                                    'time': DateTime.now(),
                                    'totalAmount': getTotalAmount(),
                                    'totalPrice': totalPrice,
                                    'vendorName': widget.vendorName,
                                  };
                                  await FirebaseFirestore.instance
                                      .collection('carts')
                                      .where('seller',
                                          isEqualTo: widget.vendorName)
                                      .get()
                                      .then((snapshot) {
                                    for (DocumentSnapshot doc
                                        in snapshot.docs) {
                                      doc.reference.delete();
                                    }
                                  });

                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc()
                                        .set(orderData);

                                    // String orderID = generateID();

                                    // final newCart = FirebaseFirestore.instance
                                    //     .collection('carts')
                                    //     .doc(orderID);
                                    // final cartData = CartModel(
                                    //     id: cardID,
                                    //     imageUrls: imageUrls,
                                    //     productName: productName,
                                    //     regularPrice: regularPrice,
                                    //     sellerName: sellerName);
                                    // await newCart.set(cartData.toJson()).then((value) =>
                                    //     showDialog(
                                    //         context: context,
                                    //         builder: (builder) => successDialog(
                                    //             context, 'Product added successfully!')));
                                    if (context.mounted) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                  title: const Text(
                                                      'Order placed'),
                                                  content: const Text(
                                                      'Order submitted! Please wait for seller\'s approval.'),
                                                  actions: [
                                                    TextButton(
                                                        child: const Text('OK'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          if (Navigator.canPop(
                                                              context)) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        })
                                                  ]));
                                    }
                                  } catch (error) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Failed to place order. Please try again later.'),
                                              backgroundColor: Colors.red));
                                    }
                                  }
                                },
                                child: const Text('Place Order',
                                    style: TextStyle(fontSize: 18)))
                          ]);
                    }))));
  }
}


// class OrderSummaryScreen extends StatefulWidget {
// final String vendorName;
// final List<Product> products;

// const OrderSummaryScreen(
// {Key? key, required this.vendorName, required this.products})
// : super(key: key);

// @override
// _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
// }

// class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
// @override
// Widget build(BuildContext context) {
// int totalPrice = widget.products.fold<int>(
//   0, (previousValue, product) => previousValue + product.regularPrice).toInt();

// return Scaffold(
//   appBar: AppBar(
//     title: Text('Order Summary'),
//   ),
//   body: SingleChildScrollView(
//     child: Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Vendor: ${widget.vendorName}',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Products:',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           Column(
//             children: widget.products
//                 .map(
//                   (product) => ListTile(
//                     title: Text(product.name),
//                     subtitle: Text('\$${product.regularPrice}'),
//                   ),
//                 )
//                 .toList(),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Total Price: \$${totalPrice.toStringAsFixed(2)}',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () async {
//               // Save the order to Firebase
//               final orderData = {
//                 'vendorName': widget.vendorName,
//                 'products': widget.products
//                     .map((product) => {
//                           'name': product.name,
//                           'price': product.regularPrice,
//                           'imageUrls': product.imageUrls
//                         })
//                     .toList(),
//                 'totalPrice': totalPrice,
//                 'timestamp': Timestamp.now()
//               };
//               await FirebaseFirestore.instance
//                   .collection('orders')
//                   .add(orderData);

//               // Clear the cart for this vendor
//               await FirebaseFirestore.instance
//                   .collection('carts')
//                   .where('seller', isEqualTo: widget.vendorName)
//                   .get()
//                   .then((snapshot) {
//                 for (DocumentSnapshot doc in snapshot.docs) {
//                   doc.reference.delete();
//                 }
//               });

//               if(Navigator.canPop(context)){
//                   Navigator.pop(context);
//                 }

//             },
//             child: Text('Place Order'),
//           ),
//         ],
//       ),
//     ),
//   ),
// );
// }
// }

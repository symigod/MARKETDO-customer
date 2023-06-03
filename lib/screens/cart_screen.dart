import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/models/order_model.dart';
import 'package:marketdo_app/models/vendor_model.dart';
import 'package:marketdo_app/screens/product_details_screen.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/api_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Stream getCarts() => FirebaseFirestore.instance
      .collection('carts')
      .where('customerID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  Stream<List<VendorModel>> getVendor(String vendorID) => FirebaseFirestore
      .instance
      .collection('vendor')
      .where('vendorID', isEqualTo: vendorID)
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => VendorModel.fromFirestore(doc)).toList());

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0, toolbarHeight: 0),
      body: StreamBuilder(
          stream: getCarts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.length != 0) {
              List<QueryDocumentSnapshot> carts = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: carts.length,
                  itemBuilder: (context, index) {
                    String cartID = carts[index].id;
                    List<dynamic> productIDs = carts[index]['productIDs'];
                    String vendorID = carts[index]['vendorID'];
                    return Card(
                        margin: const EdgeInsets.all(7),
                        shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(width: 1, color: Colors.green),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(children: [
                          Card(
                              color: Colors.green,
                              margin: EdgeInsets.zero,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5))),
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('vendor')
                                      .doc(vendorID)
                                      .snapshots(),
                                  builder: (context, vendorSnapshot) {
                                    if (vendorSnapshot.hasError) {
                                      return errorWidget(
                                          vendorSnapshot.error.toString());
                                    }
                                    if (vendorSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return loadingWidget();
                                    }
                                    if (vendorSnapshot.hasData) {
                                      DocumentSnapshot vendor =
                                          vendorSnapshot.data!;
                                      return ListTile(
                                          leading: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Image.network(
                                                      vendor['logo']))),
                                          title: Text(vendor['businessName'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          trailing: IconButton(
                                              onPressed: () =>
                                                  deleteCart(cartID),
                                              icon: const Icon(Icons.close,
                                                  color: Colors.white)));
                                    }
                                    return emptyWidget('VENDOR NOT FOUND');
                                  })),
                          FutureBuilder<List<DocumentSnapshot>>(
                              future: _fetchProducts(productIDs),
                              builder: (context, productsSnapshot) {
                                if (productsSnapshot.hasError) {
                                  return errorWidget(
                                      productsSnapshot.error.toString());
                                }
                                if (productsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return loadingWidget();
                                }
                                if (productsSnapshot.hasData) {
                                  List products = productsSnapshot.data!;
                                  double partialPrice = 0;
                                  double finalPrice = 0;
                                  double shippingCharge = 0;
                                  return Column(children: [
                                    Column(
                                        children: products.map((product) {
                                      double regularPrice =
                                          product['regularPrice'].toDouble();
                                      shippingCharge =
                                          product['shippingCharge'].toDouble();
                                      partialPrice += regularPrice;
                                      finalPrice =
                                          partialPrice /* + shippingCharge */;
                                      String formattedPrice =
                                          'P ${regularPrice.toStringAsFixed(2)}';
                                      return ListTile(
                                          dense: true,
                                          isThreeLine: true,
                                          leading: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Image.network(
                                                      product['imageURL']))),
                                          title: Text(product['productName']),
                                          subtitle: RichText(
                                              text: TextSpan(
                                                  text:
                                                      '${product['description']}\n',
                                                  style: const TextStyle(color: Colors.grey, fontFamily: 'Lato'),
                                                  children: [
                                                TextSpan(
                                                    text: formattedPrice,
                                                    style: const TextStyle(
                                                        color: Colors.red))
                                              ])),
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
                                                  'TOTAL: P ${finalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextButton(
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              OrderSummaryScreen(
                                                                  cartID:
                                                                      cartID,
                                                                  vendorID:
                                                                      vendorID,
                                                                  products:
                                                                      products,
                                                                  partialPrice:
                                                                      partialPrice,
                                                                  shippingCharge:
                                                                      shippingCharge))),
                                                  child: const Text('View more',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold)))
                                            ]))
                                  ]);
                                }
                                return emptyWidget('PRODUCTS NOT FOUND');
                              })
                        ]));
                  });
            }
            return emptyWidget('CART EMPTY');
          }));

  Future<List<DocumentSnapshot>> _fetchProducts(
      List<dynamic> productIDs) async {
    List<DocumentSnapshot> products = [];
    for (dynamic id in productIDs) {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (snapshot.exists) {
        products.add(snapshot);
      }
    }
    return products;
  }

  deleteCart(String cartID) => showDialog(
      context: context,
      builder: (_) => AlertDialog(
              title: const Text('REMOVE ALL ITEMS FROM THIS VENDOR'),
              content: const Text('Do you want to continue?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text('NO', style: TextStyle(color: Colors.red))),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await FirebaseFirestore.instance
                          .collection('carts')
                          .doc(cartID)
                          .delete()
                          .then((value) => showDialog(
                              context: context,
                              builder: (_) => successDialog(context,
                                  'Items in cart successfully removed!')));
                    },
                    child: Text('YES',
                        style: TextStyle(color: Colors.green.shade900)))
              ]));

  deleteProductInCart(String cartID, int index) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('REMOVE ITEM FROM CART'),
                content: const Text('Do you want to continue?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('NO',
                          style: TextStyle(color: Colors.red))),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        DocumentSnapshot cartSnapshot = await FirebaseFirestore
                            .instance
                            .collection('carts')
                            .doc(cartID)
                            .get();
                        List<dynamic> productIDs =
                            List<dynamic>.from(cartSnapshot['productIDs']);
                        if (index >= 0 && index < productIDs.length) {
                          productIDs.removeAt(index);
                          await FirebaseFirestore.instance
                              .collection('carts')
                              .doc(cartID)
                              .update({'productIDs': productIDs}).then(
                                  (value) async {
                            if (productIDs.isEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('carts')
                                  .doc(cartID)
                                  .delete()
                                  .then((value) => showDialog(
                                      context: context,
                                      builder: (_) => successDialog(context,
                                          'Products in cart deleted successfully!')));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (_) => successDialog(context,
                                      'Product deleted successfully!'));
                            }
                          });
                        }
                      },
                      child: Text('YES',
                          style: TextStyle(color: Colors.green.shade900)))
                ]));
  }
}

class OrderSummaryScreen extends StatefulWidget {
  final String cartID;
  final String vendorID;
  final List products;
  final double partialPrice;
  final double shippingCharge;

  const OrderSummaryScreen(
      {Key? key,
      required this.cartID,
      required this.vendorID,
      required this.products,
      required this.partialPrice,
      required this.shippingCharge})
      : super(key: key);

  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String _selectedPaymentMethod = 'cash_on_delivery';
  String _selectedShippingMethod = 'home_delivery';
  Stream getVendor(String vendorID) => FirebaseFirestore.instance
      .collection('vendor')
      .where('vendorID', isEqualTo: vendorID)
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => VendorModel.fromFirestore(doc)).toList());

  double setShippingCharge() =>
      _selectedShippingMethod == 'pick_up' ? 0 : widget.shippingCharge;

  double totalPayment() => widget.partialPrice + setShippingCharge();

  @override
  Widget build(BuildContext context) => Scaffold(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          cardWidget(context, 'VENDOR', [
                            StreamBuilder(
                                stream: getVendor(widget.vendorID),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return errorWidget(
                                        snapshot.error.toString());
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.data!.isNotEmpty) {
                                    var vendor = snapshot.data![0];
                                    return Column(children: [
                                      ListTile(
                                          dense: true,
                                          leading: const SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: Center(
                                                  child: Icon(Icons.store))),
                                          title: Text(vendor.businessName),
                                          subtitle: Text(vendor.vendorID)),
                                      ListTile(
                                          dense: true,
                                          leading: const SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: Center(
                                                  child:
                                                      Icon(Icons.location_on))),
                                          title: Text(
                                              '${vendor.city}, ${vendor.state}, ${vendor.country}'),
                                          subtitle: Text(vendor.landMark)),
                                      ListTile(
                                          onTap: () => showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                  scrollable: true,
                                                  title: const Text(
                                                      'VENDOR CONTACT'),
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  content: Column(children: [
                                                    const SizedBox(height: 20),
                                                    ListTile(
                                                        onTap: () => openURL(
                                                            context,
                                                            'tel:${vendor.mobile}'),
                                                        dense: true,
                                                        leading: const Icon(
                                                            Icons.call),
                                                        title:
                                                            Text(vendor.mobile),
                                                        trailing: IconButton(
                                                            onPressed: () =>
                                                                copyToClipboard(
                                                                    context,
                                                                    vendor
                                                                        .mobile),
                                                            icon: const Icon(
                                                                Icons.copy))),
                                                    ListTile(
                                                        onTap: () => openURL(
                                                            context,
                                                            'mailto:${vendor.email}'),
                                                        dense: true,
                                                        leading: const Icon(
                                                            Icons.email),
                                                        title:
                                                            Text(vendor.email),
                                                        trailing: IconButton(
                                                            onPressed: () =>
                                                                copyToClipboard(
                                                                    context,
                                                                    vendor
                                                                        .email),
                                                            icon: const Icon(
                                                                Icons.copy))),
                                                    const SizedBox(height: 20)
                                                  ]))),
                                          dense: true,
                                          leading: const SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: Center(
                                                  child: Icon(
                                                      Icons.perm_phone_msg))),
                                          title: Text(vendor.mobile),
                                          subtitle: Text(vendor.email))
                                    ]);
                                  }
                                  return emptyWidget('VENDOR NOT FOUND');
                                })
                          ]),
                          cardWidget(context, 'PRODUCTS', [
                            ...widget.products
                                .map((product) => ListTile(
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
                                        child:
                                            Image.network(product['imageURL'])),
                                    title: Text(product['productName']),
                                    subtitle: Text(product['description']),
                                    trailing: Text(
                                        '${product['regularPrice'].toDouble().toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold))))
                                .toList(),
                            Container(
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.green, width: 1))),
                              child: ListTile(
                                  dense: true,
                                  title: const Text('TOTAL:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  trailing: Text(
                                      'P ${widget.partialPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold))),
                            )
                          ]),
                          cardWidget(context, 'SHIPPING', [
                            ListTile(
                                title: DropdownButton<String>(
                                    value: _selectedShippingMethod,
                                    onChanged: (value) => setState(
                                        () => _selectedShippingMethod = value!),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'home_delivery',
                                          child: Text('Home Delivery')),
                                      DropdownMenuItem(
                                          value: 'pick_up',
                                          child: Text('Pick-Up'))
                                    ]),
                                trailing: Text(
                                    'P ${setShippingCharge().toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)))
                          ]),
                          cardWidget(context, 'TOTAL PAYMENT', [
                            ListTile(
                                title: DropdownButton<String>(
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
                                trailing: Text(
                                    'P ${totalPayment().toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)))
                          ]),
                          const SizedBox(height: 100),
                        ]);
                  }))),
      bottomSheet: ListTile(
          onTap: () =>
              placeOrder(totalPayment(), widget.vendorID, widget.cartID),
          tileColor: Colors.green.shade900,
          leading: const Icon(Icons.shopping_bag, color: Colors.white),
          title: const Text('Check out',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.check, color: Colors.white)));

  placeOrder(double totalPayment, String vendorID, String cartID) async =>
      showDialog(
          context: context,
          builder: (_) => confirmDialog(
                  context, 'PLACE ORDER', 'Do you want to continue?', () async {
                try {
                  final newOrder =
                      FirebaseFirestore.instance.collection('orders').doc();
                  final orderData = OrderModel(
                      customerID: FirebaseAuth.instance.currentUser!.uid,
                      orderID: newOrder.id,
                      orderStatus: 'Accepted',
                      paymentMethod: _selectedPaymentMethod,
                      productIDs: widget.products
                          .map((product) => product['productID'])
                          .toList(),
                      shippingFee: setShippingCharge(),
                      shippingMethod: _selectedShippingMethod,
                      orderedOn: DateTime.now(),
                      totalPayment: totalPayment,
                      vendorID: vendorID);

                  await FirebaseFirestore.instance
                      .collection('carts')
                      .doc(cartID)
                      .delete()
                      .then((value) => Navigator.pop(context));

                  await newOrder
                      .set(orderData.toFirestore())
                      .then((value) => showDialog(
                          context: context,
                          builder: (builder) =>
                              successDialog(context, 'Order successful!')))
                      .then((value) => Navigator.pop(context));
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (_) => errorDialog(context, e.toString()));
                }
              }));
}

Widget cardWidget(context, String title, List<Widget> contents) => Card(
    shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Colors.green),
        borderRadius: BorderRadius.circular(5)),
    child: Column(children: [
      Card(
          color: Colors.green,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5))),
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center)))),
      Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: contents)
    ]));

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

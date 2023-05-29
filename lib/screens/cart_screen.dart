import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('carts')
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
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('NOTHING IN CART'));
            }
            Map<String, List<Product>> cartItems = {};
            for (var doc in snapshot.data!.docs) {
              String vendorName = doc['sellerName'];
              Product product = Product(doc['productID'], doc['regularPrice'],
                  doc['imageUrls'], doc.id);
              if (!cartItems.containsKey(vendorName)) {
                cartItems[vendorName] = [product];
              } else {
                cartItems[vendorName]!.add(product);
              }
            }
            return ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  String vendorName = cartItems.keys.elementAt(index);
                  List<Product>? vendorProducts = cartItems[vendorName];
                  return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(vendorName,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold))),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: vendorProducts!.length,
                                itemBuilder: (context, index) {
                                  Product product = vendorProducts[index];

                                  return ListTile(
                                      title: Text(product.name),
                                      subtitle: Text(
                                          '₱${product.regularPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontFamily: 'Roboto')),
                                      leading:
                                          Image.network(product.imageUrls[0]),
                                      trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('carts')
                                                      .doc(product.id)
                                                      .delete();
                                                  setState(() => vendorProducts
                                                      .removeAt(index));
                                                },
                                                icon: const Icon(Icons.delete))
                                          ]));
                                }),
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderSummaryScreen(
                                                    vendorName: vendorName,
                                                    products: vendorProducts))),
                                    child: const Text('Checkout')))
                          ]));
                });
          }));
}

class Product {
  final String name;
  final double regularPrice;
  final List imageUrls;
  final String id; // Add a property for the document ID

  Product(this.name, this.regularPrice, this.imageUrls, this.id);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'regularPrice': regularPrice,
      'imageUrls': imageUrls,
      'id': id,
    };
  }
}

class OrderSummaryScreen extends StatefulWidget {
  final String vendorName;
  final List<Product> products;

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
                                    title: Text(widget.products[index].name),
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
                                    'products': widget.products
                                        .map((product) => product.toMap())
                                        .toList(),
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

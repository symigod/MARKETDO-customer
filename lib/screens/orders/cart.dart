import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/models/vendor.model.dart';
import 'package:marketdo_app/screens/orders/summary.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Stream getCarts() =>
      cartsCollection.where('customerID', isEqualTo: authID).snapshots();

  Stream<List<VendorModel>> getVendor(String vendorID) => vendorsCollection
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
          builder: (context, cs) {
            if (cs.hasError) {
              return errorWidget(cs.error.toString());
            }
            if (cs.connectionState == ConnectionState.waiting) {
              return loadingWidget();
            }
            if (cs.data!.docs.length != 0) {
              List<QueryDocumentSnapshot> carts = cs.data!.docs;
              return ListView.builder(
                  itemCount: carts.length,
                  itemBuilder: (context, index) {
                    String cartID = carts[index].id;
                    var cart = carts[index];
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
                                  stream: vendorsCollection
                                      .doc(vendorID)
                                      .snapshots(),
                                  builder: (context, vs) {
                                    if (vs.hasError) {
                                      return errorWidget(vs.error.toString());
                                    }
                                    if (vs.connectionState ==
                                        ConnectionState.waiting) {
                                      return loadingWidget();
                                    }
                                    if (vs.hasData) {
                                      DocumentSnapshot vendor = vs.data!;
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
                              builder: (context, ps) {
                                if (ps.hasError) {
                                  return errorWidget(ps.error.toString());
                                }
                                if (ps.connectionState ==
                                    ConnectionState.waiting) {
                                  return loadingWidget();
                                }
                                if (ps.hasData) {
                                  List products = ps.data!;
                                  double totalPayment = 0;
                                  double shippingCharge = 0;
                                  return Column(children: [
                                    Column(
                                        children: products.map((product) {
                                      List<double> paymentsList =
                                          List<double>.from(cart['payments']);
                                      int pIndex = products.indexOf(product);
                                      double payments =
                                          cart['payments'][pIndex];
                                      double unitsBought =
                                          cart['unitsBought'][pIndex];
                                      totalPayment = paymentsList.reduce(
                                          (sum, payment) => sum + payment);
                                      // shippingCharge =
                                      //     product['shippingCharge'];
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
                                          title: RichText(
                                              text: TextSpan(
                                                  style: const TextStyle(
                                                      fontFamily: 'Lato'),
                                                  children: [
                                                TextSpan(
                                                    text:
                                                        '${product['productName']}',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                    text:
                                                        ' [$unitsBought ${product['unit']}/s]',
                                                    style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ])),
                                          subtitle: RichText(
                                              text: TextSpan(
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontFamily: 'Lato'),
                                                  children: [
                                                TextSpan(
                                                    text:
                                                        '${product['description']}\n'),
                                                TextSpan(
                                                    text:
                                                        'P ${payments.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold))
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
                                    const Divider(
                                        color: Colors.green,
                                        height: 0,
                                        thickness: 1),
                                    ListTile(
                                        title: Text(
                                            'TOTAL: P ${totalPayment.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                        trailing: TextButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        OrderSummaryScreen(
                                                          cartID: cartID,
                                                          vendorID: vendorID,
                                                          payments:
                                                              cart['payments'],
                                                          products: products,
                                                          partialPrice:
                                                              totalPayment,
                                                          shippingCharge:
                                                              shippingCharge,
                                                          unitsBought: cart[
                                                              'unitsBought'],
                                                        ))),
                                            child: const Text('View more',
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold))))
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
      DocumentSnapshot snapshot = await productsCollection.doc(id).get();
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
                      await cartsCollection.doc(cartID).delete().then((value) =>
                          showDialog(
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
                        DocumentSnapshot cartSnapshot =
                            await cartsCollection.doc(cartID).get();
                        List<dynamic> productIDs =
                            List<dynamic>.from(cartSnapshot['productIDs']);
                        if (index >= 0 && index < productIDs.length) {
                          productIDs.removeAt(index);
                          await cartsCollection.doc(cartID).update(
                              {'productIDs': productIDs}).then((value) async {
                            if (productIDs.isEmpty) {
                              await cartsCollection.doc(cartID).delete().then(
                                  (value) => showDialog(
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

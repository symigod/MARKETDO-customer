import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/models/product.model.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: ordersCollection
          .where('customerID', isEqualTo: authID)
          .where('isDelivered', isEqualTo: false)
          .orderBy('orderedOn', descending: true)
          .snapshots(),
      builder: (context, os) {
        if (os.hasError) {
          return errorWidget(os.error.toString());
        }
        if (os.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (os.data!.docs.isNotEmpty) {
          var order = os.data!.docs;
          return ListView.builder(
              itemCount: order.length,
              itemBuilder: (context, index) {
                var tileColor =
                    index % 2 == 0 ? Colors.grey.shade100 : Colors.white;
                var orders = order[index];
                int quantity = orders['productIDs'].length;
                return FutureBuilder(
                    future: vendorsCollection
                        .where('vendorID', isEqualTo: orders['vendorID'])
                        .get(),
                    builder: (context, vs) {
                      if (vs.hasError) {
                        return errorWidget(vs.error.toString());
                      }
                      if (vs.connectionState == ConnectionState.waiting) {
                        return loadingWidget();
                      }
                      if (vs.data!.docs.isNotEmpty) {
                        var vendor = vs.data!.docs[0];
                        return ListTile(
                            onTap: () => viewOrderDetails(
                                orders['orderID'], orders['vendorID']),
                            dense: true,
                            tileColor: tileColor,
                            leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: vendor['isOnline']
                                            ? Colors.green
                                            : Colors.grey,
                                        width: 2)),
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2)),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CachedNetworkImage(
                                            imageUrl: vendor['logo'],
                                            fit: BoxFit.cover)))),
                            title: Text(vendor['businessName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: RichText(
                                text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 12, fontFamily: 'Lato'),
                                    children: [
                                  TextSpan(
                                      text: quantity > 1
                                          ? '$quantity items'
                                          : '$quantity item',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  TextSpan(
                                      text:
                                          '\n${dateTimeToString(orders['orderedOn'])}',
                                      style:
                                          const TextStyle(color: Colors.blue))
                                ])),
                            trailing: Text(
                                'P ${numberToString(orders['totalPayment'].toDouble())}',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)));
                      }
                      return emptyWidget('VENDOR NOT FOUND');
                    });
              });
        }
        return emptyWidget('NO PENDING ORDERS');
      });

  viewOrderDetails(String orderID, String vendorID) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
          child: SingleChildScrollView(
              child: StreamBuilder(
                  stream: ordersCollection
                      .where('orderID', isEqualTo: orderID)
                      .where('vendorID', isEqualTo: vendorID)
                      .snapshots(),
                  builder: (context, os) {
                    if (os.hasError) {
                      return errorWidget(os.error.toString());
                    }
                    if (os.connectionState == ConnectionState.waiting) {
                      return loadingWidget();
                    }
                    if (os.hasData) {
                      var order = os.data!.docs[0];
                      List<dynamic> products = order['productIDs'];
                      return AlertDialog(
                          titlePadding: EdgeInsets.zero,
                          title: StreamBuilder(
                              stream: vendorsCollection
                                  .where('vendorID', isEqualTo: vendorID)
                                  .snapshots(),
                              builder: (context, vs) {
                                if (vs.hasError) {
                                  return errorWidget(vs.error.toString());
                                }
                                if (vs.connectionState ==
                                    ConnectionState.waiting) {
                                  return loadingWidget();
                                }
                                if (vs.data!.docs.isNotEmpty) {
                                  var vendor = vs.data!.docs[0];
                                  return Card(
                                      color: Colors.green,
                                      margin: EdgeInsets.zero,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(3),
                                              topRight: Radius.circular(3))),
                                      child: ListTile(
                                          onTap: () => viewVendorDetails(
                                              context, vendor['vendorID']),
                                          leading: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: vendor['isOnline']
                                                          ? Colors
                                                              .green.shade900
                                                          : Colors.grey,
                                                      width: 2)),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                  child: ClipRRect(borderRadius: BorderRadius.circular(50), child: CachedNetworkImage(imageUrl: vendor['logo'], fit: BoxFit.cover)))),
                                          title: Text(vendor['businessName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          trailing: InkWell(onTap: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.close, color: Colors.white)))));
                                }
                                return emptyWidget('VENDOR NOT FOUND');
                              }),
                          contentPadding: EdgeInsets.zero,
                          content: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                        leading: const Icon(
                                            Icons.confirmation_number),
                                        title: const Text('Order Code:'),
                                        subtitle: Text(order['orderID'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    ListTile(
                                        leading: const Icon(Icons.date_range),
                                        title: const Text('Ordered on:'),
                                        trailing: Text(
                                            dateTimeToString(
                                                order['orderedOn']),
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold))),
                                    StreamBuilder(
                                        stream: Stream.fromFuture(Future.wait(
                                            products.map((productId) =>
                                                productsCollection
                                                    .doc(productId)
                                                    .get()))),
                                        builder: (context, ps) {
                                          if (ps.connectionState ==
                                              ConnectionState.waiting) {
                                            return loadingWidget();
                                          }
                                          if (ps.hasError) {
                                            return errorWidget(
                                                ps.error.toString());
                                          }
                                          if (!ps.hasData || ps.data!.isEmpty) {
                                            return emptyWidget(
                                                'PRODUCT NOT FOUND');
                                          }
                                          List<DocumentSnapshot>
                                              productSnapshots = ps.data!;
                                          List<ProductModel> productList =
                                              productSnapshots
                                                  .map((doc) => ProductModel
                                                      .fromFirestore(doc))
                                                  .toList();
                                          return ExpansionTile(
                                              initiallyExpanded: true,
                                              leading: const Icon(
                                                  Icons.shopping_bag),
                                              title: const Text('Products:'),
                                              trailing: const Icon(
                                                  Icons.arrow_drop_down),
                                              children: [
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        productList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      ProductModel product =
                                                          productList[index];
                                                      int pIndex = productList
                                                          .indexOf(productList[
                                                              index]);
                                                      double payments =
                                                          order['payments']
                                                              [pIndex];
                                                      double unitsBought =
                                                          order['unitsBought']
                                                              [pIndex];
                                                      return ListTile(
                                                          dense: true,
                                                          leading: SizedBox(
                                                              width: 50,
                                                              child: CachedNetworkImage(
                                                                  imageUrl: product
                                                                      .imageURL,
                                                                  fit: BoxFit
                                                                      .cover)),
                                                          title: RichText(
                                                              text: TextSpan(
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Lato'),
                                                                  children: [
                                                                TextSpan(
                                                                    text: product
                                                                        .productName,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text:
                                                                        ' [$unitsBought ${product.unit}/s]',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontWeight:
                                                                            FontWeight.bold))
                                                              ])),
                                                          trailing: Text(
                                                              'P ${numberToString(payments)}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)));
                                                    })
                                              ]);
                                        }),
                                    ListTile(
                                        leading:
                                            const Icon(Icons.delivery_dining),
                                        title: const Text('Delivery:'),
                                        subtitle: Text(
                                            order['deliveryMethod'] ==
                                                    'DELIVERY'
                                                ? 'Home Delivery'
                                                : 'Pick-up'),
                                        trailing: Text(
                                            'P ${numberToString(order['deliveryFee'].toDouble())}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold))),
                                    ListTile(
                                        onTap: () => order['paymentMethod'] ==
                                                'GCASH'
                                            ? showDialog(
                                                context: context,
                                                builder: (_) => Center(
                                                    child: SingleChildScrollView(
                                                        child: AlertDialog(
                                                            titlePadding:
                                                                EdgeInsets.zero,
                                                            title: Card(
                                                                color: Colors
                                                                    .green,
                                                                margin: EdgeInsets
                                                                    .zero,
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(3),
                                                                        topRight: Radius.circular(3))),
                                                                child: ListTile(title: const Text('GCASH Attachment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), trailing: InkWell(onTap: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.close, color: Colors.white))))),
                                                            content: CachedNetworkImage(imageUrl: order['attachment'])))))
                                            : null,
                                        leading: const Icon(Icons.payments),
                                        title: const Text('Payment:'),
                                        subtitle: Text('${order['paymentMethod'] == 'COD' ? 'Cash on Delivery' : order['paymentMethod']}'),
                                        trailing: Text('P ${numberToString(order['totalPayment'].toDouble())}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))
                                  ])));
                    }
                    return emptyWidget('ORDER NOT FOUND');
                  }))));
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/widgets/api_widgets.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('customerID',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                    future: FirebaseFirestore.instance
                        .collection('vendor')
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
                            onTap: () => viewOrderDetails(orders['orderID']),
                            dense: true,
                            tileColor: tileColor,
                            leading: SizedBox(
                                height: 40,
                                width: 40,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(vendor['logo'],
                                        fit: BoxFit.cover))),
                            title: Text(vendor['businessName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(quantity > 1
                                ? '$quantity items'
                                : '$quantity item'),
                            trailing: Text(
                                'P ${orders['totalPayment'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)));
                      }
                      return emptyWidget('VENDOR NOT FOUND');
                    });
              });
        }
        return emptyWidget('NO ORDERS YET');
      });

  viewOrderDetails(String orderID) =>
      showDialog(context: context, builder: (_) => AlertDialog());
}

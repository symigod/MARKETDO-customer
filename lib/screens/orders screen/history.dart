import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('customerID',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('orderStatus', isEqualTo: 'delivered')
          .orderBy('orderedOn', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isNotEmpty) {
          var order = snapshot.data!.docs;
          return ListView.builder(
              itemCount: order.length,
              itemBuilder: (context, index) {
                var orders = order[index];
                Timestamp timestamp = orders['orderedOn'];
                String time = timestamp.toDate().toUtc().toString();
                int quantity = orders['productIDs'].length;
                return ListTile(
                    isThreeLine: true,
                    leading: Text('${index + 1}'),
                    title: Text(time,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        quantity > 1 ? '$quantity items' : '$quantity item'),
                    trailing: Text(
                        'P ${orders['totalPayment'].toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)));
              });
        }
        return const Center(child: Text('NO ORDERS YET'));
      });
}

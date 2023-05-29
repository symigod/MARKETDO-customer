import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/screens/orders%20screen/orders_details.dart';

class OrderScreen extends StatefulWidget {
  final Stream stream;
  const OrderScreen({super.key, required this.stream});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String customerID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title:
              const Text('My Orders', style: TextStyle(color: Colors.white))),
      body: StreamBuilder(
          stream: widget.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            List<DocumentSnapshot> documents = snapshot.data!.docs;
            if (documents.isEmpty) {
              return const Center(child: Text('NO ORDERS YET'));
            }
            return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot document = documents[index];
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  Timestamp timestamp = data['time'];
                  String time = timestamp.toDate().toUtc().toString();
                  String orderStatus = data['orderStatus'];
                  return ListTile(
                      leading: Text('${index + 1}'),
                      title: Text(time,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      subtitle: Text(orderStatus.toString()),
                      trailing: IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      OrderDetails(time: timestamp))),
                          icon: const Icon(Icons.arrow_forward_outlined)));
                });
          }));
}

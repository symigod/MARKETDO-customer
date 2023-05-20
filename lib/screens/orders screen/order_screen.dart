import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/screens/orders%20screen/orders_details.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final CollectionReference _orders =
      FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _orders.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            List<DocumentSnapshot> documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot document = documents[index];

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                Timestamp timestamp = data['time'];
                String time = timestamp.toDate().toUtc().toString();
                double totalAmount = data['totalAmount'];

                return ListTile(
                  leading: Text('${index + 1}'), //automatic numbers dapat ni
                  title: Text(
                    time,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(totalAmount.toString()),
                  trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    OrderDetails(time: timestamp)));
                      },
                      icon: const Icon(Icons.arrow_forward_outlined)),
                );
              },
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

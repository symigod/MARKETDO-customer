import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class OrderDetails extends StatelessWidget {
  final Timestamp time;
  const OrderDetails({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: const Text('Order Details',
                style: TextStyle(color: Colors.white))),
        body: StreamBuilder(
            // stream: getSingleOrder(time),
            builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorWidget(snapshot.error.toString());
          } else {
            if (!snapshot.hasData) {
              return emptyWidget('NO RECORD FOUND!');
            } else {
              return loadingWidget();
            }
          }
        }));
  }
}

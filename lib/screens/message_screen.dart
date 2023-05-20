import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Container(
        child: const Center(
          child: Text('Message Screen',
            style: TextStyle(
              fontSize: 50, fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}

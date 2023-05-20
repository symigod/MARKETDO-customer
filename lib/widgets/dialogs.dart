import 'package:flutter/material.dart';

Widget successDialog(BuildContext context, String message) {
  return AlertDialog(
    title: Text('SUCCESS'),
    content: Text(message),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
    ],
  );
}

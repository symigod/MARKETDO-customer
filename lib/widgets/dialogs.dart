import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Widget confirmDialog(
        context, String title, String message, void Function() onPressed) =>
    AlertDialog(title: Text(title), content: Text(message), actions: [
      TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('NO', style: TextStyle(color: Colors.red))),
      TextButton(
          onPressed: onPressed,
          child: Text('YES', style: TextStyle(color: Colors.green.shade900)))
    ]);

Widget errorDialog(BuildContext context, String message) =>
    AlertDialog(title: const Text('ERROR'), content: Text(message), actions: [
      TextButton(
          onPressed: () => Navigator.pop(context), child: const Text('OK'))
    ]);

Widget successDialog(BuildContext context, String message) => AlertDialog(
        /* title: const Text('SUCCESS'),  */ title: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ]);

Future<void> openURL(context, String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    showDialog(
        context: context,
        builder: (_) => errorDialog(context, 'Cannot open "$url"'));
  }
}

String dateTimeToString(Timestamp timestamp) =>
    DateFormat('MMM dd, yyyy').format(timestamp.toDate()).toString();

String numberToString(double number) => NumberFormat('#,###.##').format(number);

Text decimalToFraction(double value, String unit, double fontSize) {
  const int maxDenominator = 1000000;

  int whole = value.floor();
  double decimal = value - whole;

  if (decimal == 0) {
    return Text(whole.toString(), style: TextStyle(fontSize: fontSize));
  }

  int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  int numerator = (decimal * maxDenominator).toInt();
  int denominator = maxDenominator;

  int greatestCommonDivisor = gcd(numerator, denominator);
  numerator ~/= greatestCommonDivisor;
  denominator ~/= greatestCommonDivisor;

  return Text.rich(
      TextSpan(children: [
        TextSpan(text: '$whole ', style: TextStyle(fontSize: fontSize)),
        TextSpan(
            text: '$numerator/$denominator',
            style: TextStyle(
                fontSize: fontSize * 0.8, fontWeight: FontWeight.normal)),
        TextSpan(text: ' $unit', style: TextStyle(fontSize: fontSize)),
      ]),
      style: const TextStyle(fontWeight: FontWeight.bold));
}

void copyToClipboard(context, String copyText) =>
    FlutterClipboard.copy(copyText).then((value) => showSnackbar(context));

showSnackbar(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Text copied!', textAlign: TextAlign.center)));

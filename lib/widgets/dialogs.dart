import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
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

void copyToClipboard(context, String copyText) =>
    FlutterClipboard.copy(copyText).then((value) => showSnackbar(context));

showSnackbar(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Text copied!', textAlign: TextAlign.center)));

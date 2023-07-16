import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/widgets/snapshots.dart';
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

Widget cardWidget(context, String title, List<Widget> contents) => Card(
    shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Colors.green),
        borderRadius: BorderRadius.circular(5)),
    child: Column(children: [
      Card(
          color: Colors.green,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5))),
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center)))),
      Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: contents)
    ]));

viewVendorDetails(context, String vendorID) => showDialog(
    context: context,
    builder: (_) => FutureBuilder(
        future: vendorsCollection.where('vendorID', isEqualTo: vendorID).get(),
        builder: (context, vs) {
          if (vs.hasError) {
            return errorWidget(vs.error.toString());
          }
          if (vs.connectionState == ConnectionState.waiting) {
            return loadingWidget();
          }
          if (vs.data!.docs.isNotEmpty) {
            var vendor = vs.data!.docs[0];
            return AlertDialog(
                scrollable: true,
                contentPadding: EdgeInsets.zero,
                content: Column(children: [
                  SizedBox(
                      height: 150,
                      child: DrawerHeader(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          child: Stack(alignment: Alignment.center, children: [
                            Container(
                                padding: const EdgeInsets.all(20),
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        topRight: Radius.circular(3)),
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(vendor['shopImage']),
                                        fit: BoxFit.cover))),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: vendor['isOnline']
                                                  ? Colors.green
                                                  : Colors.grey,
                                              width: 3)),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 3)),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(130),
                                              child: CachedNetworkImage(
                                                  imageUrl: vendor['logo'],
                                                  fit: BoxFit.cover))))
                                ])
                          ]))),
                  ListTile(
                      dense: true,
                      isThreeLine: true,
                      leading: const Icon(Icons.store),
                      title: Text(vendor['businessName'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: FittedBox(
                          child: Text('Vendor ID:\n${vendor['vendorID']}'))),
                  ListTile(
                      dense: true,
                      leading: const Icon(Icons.perm_phone_msg),
                      title: Text(vendor['mobile']),
                      subtitle: Text(vendor['email'])),
                  ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on),
                      title: Text(vendor['address']),
                      subtitle: Text(vendor['landMark'])),
                  ListTile(
                      dense: true,
                      leading: const Icon(Icons.date_range),
                      title: const Text('REGISTERED ON:'),
                      subtitle: Text(dateTimeToString(vendor['registeredOn'])))
                ]),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.red)),
                  IconButton(
                      onPressed: () =>
                          openURL(context, 'mailto:${vendor['email']}'),
                      icon: const Icon(Icons.mail, color: Colors.blue)),
                  IconButton(
                      onPressed: () =>
                          openURL(context, 'tel:${vendor['mobile']}'),
                      icon: const Icon(Icons.call, color: Colors.green)),
                ]);
          }
          return emptyWidget('VENDOR NOT FOUND');
        }));

Future<void> openURL(context, String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    showDialog(
        context: context,
        builder: (_) => errorDialog(context, 'Cannot open "$url"'));
  }
}

String dateTimeToString(Timestamp timestamp) =>
    DateFormat('MMM dd, yyyy').format(timestamp.toDate()).toString();

String numberToString(double number) => NumberFormat('#,###.00').format(number);

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

FaIcon categoryIcon(category) {
  switch (category) {
    case 'Clothing and Accessories':
      category = FontAwesomeIcons.shirt;
      break;

    case 'Food and Beverages':
      category = FontAwesomeIcons.utensils;
      break;

    case 'Household Items':
      category = FontAwesomeIcons.couch;
      break;

    case 'Personal Care':
      category = FontAwesomeIcons.handSparkles;
      break;

    case 'School and Office Supplies':
      category = FontAwesomeIcons.folderOpen;
      break;

    case 'Others':
      category = FontAwesomeIcons.ellipsis;
      break;
  }
  return FaIcon(category);
}

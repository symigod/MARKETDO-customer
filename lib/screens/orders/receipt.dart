import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/main.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptScreen extends StatefulWidget {
  final String orderID;

  const ReceiptScreen({super.key, required this.orderID});

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final MaterialColor _marketDoGreen = MaterialColor(marketDoGreen, {
    50: const Color(0xFFE8F5E9),
    100: const Color(0xFFC8E6C9),
    200: const Color(0xFFA5D6A7),
    300: const Color(0xFF81C784),
    400: const Color(0xFF66BB6A),
    500: Color(marketDoGreen),
    600: const Color(0xFF43A047),
    700: const Color(0xFF388E3C),
    800: const Color(0xFF2E7D32),
    900: const Color(0xFF1B5E20)
  });
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: _marketDoGreen, fontFamily: 'RobotoMono'),
      home: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back)),
              centerTitle: true,
              title: const Text('Order Receipt',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                    icon: const Icon(Icons.print), onPressed: () => _printPdf())
              ]),
          body: StreamBuilder(
              stream: ordersCollection.doc(widget.orderID).snapshots(),
              builder: (context, os) {
                if (os.connectionState == ConnectionState.waiting) {
                  return loadingWidget();
                }
                if (os.hasError) {
                  return errorWidget(os.error.toString());
                }
                if (!os.hasData || !os.data!.exists) {
                  return emptyWidget('ORDER NOT FOUND');
                }
                var orderData = os.data!;
                return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: SizedBox(
                                    height: 75,
                                    width: 75,
                                    child: Image.asset(
                                        'assets/images/marketdoLogo.png'))),
                            const SizedBox(height: 10),
                            const Center(
                                child: Text('MARKETDO APP',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(height: 50),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Order Code:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(orderData['orderID'])
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Order Date:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(DateFormat('MM-dd-yyyy, hh:mm a').format(
                                      (orderData['orderedOn'] as Timestamp)
                                          .toDate()))
                                ]),
                            const Divider(height: 30, thickness: 2),
                            StreamBuilder(
                                stream: vendorsCollection
                                    .where('vendorID',
                                        isEqualTo: orderData['vendorID'])
                                    .snapshots(),
                                builder: (context, vs) {
                                  if (vs.connectionState ==
                                      ConnectionState.waiting) {
                                    return loadingWidget();
                                  }
                                  if (vs.hasError) {
                                    return errorWidget(vs.error.toString());
                                  }
                                  if (vs.hasData) {
                                    return Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Vendor:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(vs.data!.docs[0]
                                                ['businessName'])
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Contact Number:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(vs.data!.docs[0]['mobile'])
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Email Address:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(vs.data!.docs[0]['email'])
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Address:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${vs.data!.docs[0]['address']}')
                                          ])
                                    ]);
                                  }
                                  return emptyWidget('VENDOR NOT FOUND');
                                }),
                            const Divider(height: 30, thickness: 2),
                            StreamBuilder(
                                stream: customersCollection
                                    .where('customerID',
                                        isEqualTo: orderData['customerID'])
                                    .snapshots(),
                                builder: (context, cs) {
                                  if (cs.connectionState ==
                                      ConnectionState.waiting) {
                                    return loadingWidget();
                                  }
                                  if (cs.hasError) {
                                    return errorWidget(cs.error.toString());
                                  }
                                  if (cs.hasData) {
                                    return Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Customer:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(cs.data!.docs[0]['name'])
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Contact Number:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(cs.data!.docs[0]['mobile'])
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Email Address:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(cs.data!.docs[0]['email'])
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Address:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${cs.data!.docs[0]['address']}')
                                          ])
                                    ]);
                                  }
                                  return emptyWidget('CUSTOMER NOT FOUND');
                                }),
                            FutureBuilder(
                                future: _fetchProducts(orderData['productIDs']),
                                builder: (context, ps) {
                                  if (ps.connectionState ==
                                      ConnectionState.waiting) {
                                    return loadingWidget();
                                  }
                                  if (ps.hasError) {
                                    return errorWidget(ps.error.toString());
                                  }
                                  List<dynamic> productList = ps.data!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Table(
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        border: TableBorder.all(
                                            width: 1, color: Colors.grey),
                                        children: [
                                          const TableRow(children: [
                                            TableCell(
                                                child: Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text('ITEM',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))))),
                                            TableCell(
                                                child: Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'UNIT PRICE',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))))),
                                            TableCell(
                                                child: Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'QUANTITY / UNIT',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))))
                                          ]),
                                          ...productList.map((product) =>
                                              TableRow(children: [
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(product[
                                                            'productName']))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            'P ${numberToString(product['regularPrice'].toDouble())}',
                                                            textAlign: TextAlign
                                                                .end))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            '${orderData['unitsBought'][productList.indexOf(product)]} ${product['unit']}/s',
                                                            textAlign:
                                                                TextAlign.end)))
                                              ]))
                                        ]),
                                  );
                                }),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Delivery Method:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(orderData['deliveryMethod'] == 'DELIVERY'
                                      ? 'Home Delivery'
                                      : 'Pick-up')
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Delivery Fee:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      'P ${numberToString(orderData['deliveryFee'].toDouble())}')
                                ]),
                            const Divider(thickness: 2, height: 30),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Payment Method:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(orderData['paymentMethod'] == 'COD'
                                      ? 'Cash on Delivery'
                                      : orderData['paymentMethod'])
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Payment:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      'P ${numberToString(orderData['totalPayment'].toDouble())}')
                                ]),
                            const Divider(thickness: 2, height: 30),
                            const Center(
                                child: Text('Thank you for your purchase!',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)))
                          ]),
                    ));
              })));

  Future<List<dynamic>> _fetchProducts(List<dynamic> productIDs) async {
    List<dynamic> productList = [];
    for (String productId in productIDs) {
      DocumentSnapshot productSnapshot =
          await productsCollection.doc(productId).get();
      if (productSnapshot.exists) {
        productList.add(productSnapshot.data());
      }
    }
    return productList;
  }

  Future<void> _printPdf() async {
    final doc = pw.Document();
    final orderData =
        (await ordersCollection.doc(widget.orderID).get()).data()!;
    final productList = await _fetchProducts(orderData['productIDs']);
    final vendorData = (await vendorsCollection
            .where('vendorID', isEqualTo: orderData['vendorID'])
            .get())
        .docs
        .first
        .data();
    final customerData = (await customersCollection
            .where('customerID', isEqualTo: orderData['customerID'])
            .get())
        .docs
        .first
        .data();
    final font = await fontFromAssetBundle(
        'assets/fonts/RobotoMono-VariableFont_wght.ttf');
    final image = await imageFromAssetBundle('assets/images/marketdoLogo.png');
    doc.addPage(pw.Page(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                      child: pw.SizedBox(
                          height: 75, width: 75, child: pw.Image(image))),
                  pw.SizedBox(height: 10),
                  pw.Center(
                      child: pw.Text('MARKETDO APP',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 50),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Order Code:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(orderData['orderID'])
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Order Date:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            DateFormat('MM-dd-yyyy, hh:mm a').format(
                                (orderData['orderedOn'] as Timestamp).toDate()),
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Divider(height: 20),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Business Name:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(vendorData['businessName'],
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Contact Number:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(vendorData['mobile'],
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Email Address:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(vendorData['email'],
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Address:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${vendorData['address']}',
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Divider(height: 20),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Customer:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(customerData['name'],
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Contact Number:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(customerData['mobile'],
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Email Address:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(customerData['email'],
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Address:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${customerData['address']}',
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.SizedBox(height: 10),
                  pw.Table(
                      defaultVerticalAlignment:
                          pw.TableCellVerticalAlignment.middle,
                      border:
                          pw.TableBorder.all(width: 1, color: PdfColors.grey),
                      children: [
                        pw.TableRow(children: [
                          pw.Container(
                              child: pw.Center(
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('ITEM',
                                          style: pw.TextStyle(
                                              font: font,
                                              fontWeight:
                                                  pw.FontWeight.bold))))),
                          pw.Container(
                              child: pw.Center(
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('UNIT PRICE',
                                          style: pw.TextStyle(
                                              font: font,
                                              fontWeight:
                                                  pw.FontWeight.bold))))),
                          pw.Container(
                              child: pw.Center(
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('QUANTITY / UNIT',
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                              font: font,
                                              fontWeight:
                                                  pw.FontWeight.bold)))))
                        ]),
                        ...productList.map((product) => pw.TableRow(children: [
                              pw.Container(
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(product['productName'],
                                          style: pw.TextStyle(font: font)))),
                              pw.Container(
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(
                                          'P ${numberToString(product['regularPrice'].toDouble())}',
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(font: font)))),
                              pw.Container(
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(
                                          '${orderData['unitsBought'][productList.indexOf(product)]} ${product['unit']}/s',
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(font: font))))
                            ]))
                      ]),
                  pw.SizedBox(height: 10),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Delivery Method:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            orderData['deliveryMethod'] == 'DELIVERY'
                                ? 'Home Delivery'
                                : 'Pick-up',
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Delivery Fee:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            'P ${numberToString(orderData['deliveryFee'].toDouble())}',
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Divider(height: 20),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Payment Method:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            '${orderData['paymentMethod'] == 'COD' ? 'Cash on Delivery' : orderData['paymentMethod']}',
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Payment:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            'P ${numberToString(orderData['totalPayment'].toDouble())}',
                            style: pw.TextStyle(font: font))
                      ]),
                  pw.SizedBox(height: 30),
                  pw.Center(
                      child: pw.Text('Thank you for your purchase!',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold))),
                ])));
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }
}

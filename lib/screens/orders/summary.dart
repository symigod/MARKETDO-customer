import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/models/order.model.dart';
import 'package:marketdo_app/models/vendor.model.dart';
import 'package:marketdo_app/screens/main.screen.dart';
import 'package:marketdo_app/screens/products/details.product.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String cartID;
  final String vendorID;
  final List payments;
  final List products;
  final List unitsBought;
  final double partialPrice;

  const OrderSummaryScreen(
      {Key? key,
      required this.cartID,
      required this.vendorID,
      required this.payments,
      required this.products,
      required this.partialPrice,
      required this.unitsBought})
      : super(key: key);

  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String _selectedPaymentMethod = 'COD';
  String _selectedShippingMethod = 'DELIVERY';
  double deliveryFee = 0;
  Stream getVendor(String vendorID) => vendorsCollection
      .where('vendorID', isEqualTo: vendorID)
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => VendorModel.fromFirestore(doc)).toList());
  double setDeliveryFee() =>
      _selectedShippingMethod == 'PICKUP' ? 0 : deliveryFee;
  double totalPayment() => widget.partialPrice + setDeliveryFee();

  final ImagePicker _picker = ImagePicker();
  XFile? attachment;
  Future<XFile?> _pickImage() async =>
      await _picker.pickImage(source: ImageSource.gallery);

  _scaffold(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            })));
  }

  @override
  void initState() {
    setState(() => deliveryFee = widget.partialPrice * 0.01);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Order Summary',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                  stream: cartsCollection
                      .where('customerID', isEqualTo: authID)
                      .where('cartID', isEqualTo: widget.cartID)
                      .snapshots(),
                  builder: (context, cs) {
                    if (cs.hasError) {
                      return errorWidget(cs.error.toString());
                    }
                    if (cs.connectionState == ConnectionState.waiting) {
                      return loadingWidget();
                    }
                    if (cs.hasData) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            cardWidget(context, 'VENDOR', [
                              StreamBuilder(
                                  stream: vendorsCollection
                                      .where('vendorID',
                                          isEqualTo: widget.vendorID)
                                      .snapshots(),
                                  builder: (context, vs) {
                                    if (vs.hasError) {
                                      return errorWidget(vs.error.toString());
                                    }
                                    if (vs.connectionState ==
                                        ConnectionState.waiting) {
                                      return loadingWidget();
                                    }
                                    if (vs.hasData) {
                                      return ListTile(
                                          dense: true,
                                          leading: SizedBox(
                                              height: 35,
                                              width: 35,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Image.network(vs
                                                      .data!.docs[0]['logo']))),
                                          title: Text(
                                              vs.data!.docs[0]['businessName']),
                                          trailing: TextButton(
                                              onPressed: () =>
                                                  viewVendorDetails(
                                                      context,
                                                      vs.data!.docs[0]
                                                          ['vendorID']),
                                              child:
                                                  const Text('View Details')));
                                    }
                                    return emptyWidget('VENDOR NOT FOUND');
                                  })
                            ]),
                            cardWidget(context, 'PRODUCTS', [
                              ...widget.products.map((product) {
                                int pIndex = widget.products.indexOf(product);
                                double payments = widget.payments[pIndex];
                                double unitsBought = widget.unitsBought[pIndex];
                                return ListTile(
                                    dense: true,
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ProductDetailScreen(
                                                productID:
                                                    product['productID']))),
                                    leading: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: CachedNetworkImage(
                                                imageUrl: product['imageURL'],
                                                fit: BoxFit.cover))),
                                    title: Text(product['productName'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        '$unitsBought ${product['unit']}/s'),
                                    trailing: Text(numberToString(payments),
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)));
                              }).toList(),
                              const Divider(
                                  color: Colors.green, height: 0, thickness: 1),
                              ListTile(
                                  dense: true,
                                  title: const Text('TOTAL:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  trailing: Text(
                                      'P ${numberToString(widget.partialPrice)}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)))
                            ]),
                            cardWidget(context, 'DELIVERY', [
                              ListTile(
                                  title: DropdownButtonFormField<String>(
                                      isDense: true,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder()),
                                      value: _selectedShippingMethod,
                                      onChanged: (value) => setState(() =>
                                          _selectedShippingMethod = value!),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'DELIVERY',
                                            child: Text('Home Delivery')),
                                        DropdownMenuItem(
                                            value: 'PICKUP',
                                            child: Text('Pick-Up'))
                                      ]),
                                  trailing: Text(
                                      'P ${numberToString(setDeliveryFee())}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)))
                            ]),
                            cardWidget(context, 'PAYMENT', [
                              ListTile(
                                  title: DropdownButtonFormField<String>(
                                      isDense: true,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder()),
                                      value: _selectedPaymentMethod,
                                      onChanged: (value) => setState(() =>
                                          _selectedPaymentMethod = value!),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'COD',
                                            child: Text('Cash on Delivery')),
                                        DropdownMenuItem(
                                            value: 'GCASH',
                                            child: Text('Gcash'))
                                      ]),
                                  trailing: Text(
                                      'P ${numberToString(totalPayment())}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold))),
                              if (_selectedPaymentMethod == 'GCASH')
                                attachment == null
                                    ? ElevatedButton(
                                        onPressed: () => _pickImage().then(
                                            (value) => setState(
                                                () => attachment = value)),
                                        child: const Text('Add attachment'))
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                            Container(
                                                height: 200,
                                                width: 200,
                                                margin: const EdgeInsets.all(5),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Image.file(
                                                        File(attachment!.path),
                                                        fit: BoxFit.cover))),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.7)),
                                                onPressed: () => _pickImage()
                                                    .then((value) => setState(
                                                        () => attachment =
                                                            value)),
                                                child: Text('Change',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .green.shade900)))
                                          ])
                            ]),
                            const SizedBox(height: 100),
                          ]);
                    }
                    return emptyWidget('CART DETAILS NOT FOUND');
                  }))),
      bottomSheet: ListTile(
          onTap: () =>
              placeOrder(totalPayment(), widget.vendorID, widget.cartID),
          tileColor: Colors.green.shade900,
          title:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.shopping_cart_checkout, color: Colors.white),
            SizedBox(width: 10),
            Text('CHECK OUT',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)
          ])));

  placeOrder(double totalPayment, String vendorID, String cartID) async =>
      _selectedPaymentMethod == 'GCASH' && attachment == null
          ? _scaffold('Please provide proof of GCASH payment')
          : showDialog(
              context: context,
              builder: (_) => confirmDialog(
                      context,
                      'Payment: P ${totalPayment.toStringAsFixed(2)}',
                      'Make sure everything is correct. Once order is placed, you cannot undo it. Do you want to continue?',
                      () async {
                    FirebaseService fbService = FirebaseService();
                    EasyLoading.show(status: 'Placing order...');
                    try {
                      late String attachmentURL = '';
                      final newOrder = ordersCollection.doc();
                      String orderID = newOrder.id;
                      if (attachment != null) {
                        try {
                          String? url = await fbService.uploadImage(attachment,
                              'attachments/gcash/$orderID/${attachment!.name}');
                          setState(() => attachmentURL = url);
                        } catch (e) {
                          showDialog(
                              context: context,
                              builder: (_) => errorDialog(context,
                                  'Cannot upload attachment! ${e.toString()}'));
                        }
                      }
                      final orderData = OrderModel(
                          attachment: attachmentURL,
                          customerID: authID,
                          isDelivered: false,
                          orderID: orderID,
                          paymentMethod: _selectedPaymentMethod,
                          productIDs: widget.products
                              .map((product) => product['productID'])
                              .toList(),
                          deliveryFee: setDeliveryFee(),
                          deliveryMethod: _selectedShippingMethod,
                          orderedOn: DateTime.now(),
                          totalPayment: totalPayment,
                          vendorID: vendorID,
                          payments: widget.payments,
                          unitsBought: widget.unitsBought);

                      await cartsCollection
                          .doc(cartID)
                          .delete()
                          .then((value) => Navigator.pop(context));

                      await newOrder
                          .set(orderData.toFirestore())
                          .then((value) => EasyLoading.dismiss())
                          .then((value) => showDialog(
                              context: context,
                              builder: (builder) =>
                                  successDialog(context, 'Order successful!')))
                          .then((value) => Navigator.pushNamedAndRemoveUntil(
                              context, MainScreen.id, (route) => false));
                    } catch (e) {
                      EasyLoading.dismiss();
                      showDialog(
                          context: context,
                          builder: (_) => errorDialog(context, e.toString()));
                    }
                  }));
}

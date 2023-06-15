import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/models/order.model.dart';
import 'package:marketdo_app/models/vendor.model.dart';
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
  final double shippingCharge;

  const OrderSummaryScreen(
      {Key? key,
      required this.cartID,
      required this.vendorID,
      required this.payments,
      required this.products,
      required this.partialPrice,
      required this.shippingCharge,
      required this.unitsBought})
      : super(key: key);

  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String _selectedPaymentMethod = 'COD';
  String _selectedShippingMethod = 'DELIVERY';
  Stream getVendor(String vendorID) => vendorsCollection
      .where('vendorID', isEqualTo: vendorID)
      .snapshots()
      .map((vendor) =>
          vendor.docs.map((doc) => VendorModel.fromFirestore(doc)).toList());
  double setShippingCharge() =>
      _selectedShippingMethod == 'PICKUP' ? 0 : widget.shippingCharge;
  double totalPayment() => widget.partialPrice + setShippingCharge();

  final ImagePicker _picker = ImagePicker();
  XFile? attachment;
  String? attachmentURL;
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
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
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
                                  stream: getVendor(widget.vendorID),
                                  builder: (context, vs) {
                                    if (vs.hasError) {
                                      return errorWidget(vs.error.toString());
                                    }
                                    if (vs.connectionState ==
                                        ConnectionState.waiting) {
                                      return loadingWidget();
                                    }
                                    if (vs.data!.isNotEmpty) {
                                      var vendor = vs.data![0];
                                      return Column(children: [
                                        ListTile(
                                            dense: true,
                                            leading: const SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Center(
                                                    child: Icon(Icons.store))),
                                            title: Text(vendor.businessName),
                                            subtitle: Text(vendor.vendorID)),
                                        ListTile(
                                            dense: true,
                                            leading: const SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Center(
                                                    child: Icon(
                                                        Icons.location_on))),
                                            title: Text(vendor.address),
                                            subtitle: Text(vendor.landMark)),
                                        ListTile(
                                            onTap: () => showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                    scrollable: true,
                                                    title: const Text(
                                                        'VENDOR CONTACT'),
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    content: Column(children: [
                                                      const SizedBox(
                                                          height: 20),
                                                      ListTile(
                                                          onTap: () => openURL(
                                                              context,
                                                              'tel:${vendor.mobile}'),
                                                          dense: true,
                                                          leading: const Icon(
                                                              Icons.call),
                                                          title: Text(
                                                              vendor.mobile),
                                                          trailing: IconButton(
                                                              onPressed: () =>
                                                                  copyToClipboard(
                                                                      context,
                                                                      vendor
                                                                          .mobile),
                                                              icon: const Icon(
                                                                  Icons.copy))),
                                                      ListTile(
                                                          onTap: () => openURL(
                                                              context,
                                                              'mailto:${vendor.email}'),
                                                          dense: true,
                                                          leading: const Icon(
                                                              Icons.email),
                                                          title: Text(
                                                              vendor.email),
                                                          trailing: IconButton(
                                                              onPressed: () =>
                                                                  copyToClipboard(
                                                                      context,
                                                                      vendor
                                                                          .email),
                                                              icon: const Icon(
                                                                  Icons.copy))),
                                                      const SizedBox(height: 20)
                                                    ]))),
                                            dense: true,
                                            leading: const SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Center(
                                                    child: Icon(
                                                        Icons.perm_phone_msg))),
                                            title: Text(vendor.mobile),
                                            subtitle: Text(vendor.email))
                                      ]);
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
                                    trailing: Text(
                                        payments.toDouble().toStringAsFixed(2),
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
                                      'P ${widget.partialPrice.toStringAsFixed(2)}',
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
                                      'P ${setShippingCharge().toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)))
                            ]),
                            cardWidget(context, 'TOTAL PAYMENT', [
                              _selectedShippingMethod == 'PICKUP'
                                  ? ListTile(
                                      title: Text(
                                          'P ${totalPayment().toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center))
                                  : ListTile(
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
                                                child:
                                                    Text('Cash on Delivery')),
                                            DropdownMenuItem(
                                                value: 'GCASH',
                                                child: Text('Gcash'))
                                          ]),
                                      trailing: Text(
                                          'P ${totalPayment().toStringAsFixed(2)}',
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
          leading: const Icon(Icons.shopping_bag, color: Colors.white),
          title: const Text('Check out',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.check, color: Colors.white)));

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
                      final newOrder = ordersCollection.doc();
                      String orderID = newOrder.id;
                      if (attachment != null) {
                        fbService
                            .uploadImage(attachment,
                                'attachments/gcash/$orderID/${attachment!.name}')
                            .then((String? url) {
                          if (url != null) {
                            setState(() => attachmentURL = url);
                          }
                        });
                      }
                      final orderData = OrderModel(
                          attachment: _selectedPaymentMethod == 'GCASH'
                              ? attachmentURL
                              : null,
                          customerID: authID,
                          isPending: true,
                          orderID: orderID,
                          paymentMethod: _selectedPaymentMethod,
                          productIDs: widget.products
                              .map((product) => product['productID'])
                              .toList(),
                          shippingFee: setShippingCharge(),
                          shippingMethod: _selectedShippingMethod,
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
                          .then((value) => Navigator.pop(context));
                    } catch (e) {
                      EasyLoading.dismiss();
                      showDialog(
                          context: context,
                          builder: (_) => errorDialog(context, e.toString()));
                    }
                  }));
}

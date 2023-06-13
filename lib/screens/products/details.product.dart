import 'package:awesome_number_picker/awesome_number_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/models/cart.model.dart';
import 'package:marketdo_app/models/favorite.model.dart';
import 'package:marketdo_app/models/product.model.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productID;
  const ProductDetailScreen({super.key, required this.productID});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final store = GetStorage();
  ScrollController? _scrollController;
  int? pageNumber = 0;
  bool _isScrollDown = false;
  bool _showAppBar = true;
  // String? _selectedSize;

  @override
  void initState() {
    // getSize();
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      if (_scrollController!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!_isScrollDown) {
          setState(() {
            _isScrollDown = true;
            _showAppBar = false;
          });
        }
      }
      if (_scrollController!.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_isScrollDown) {
          setState(() {
            _isScrollDown = false;
            _showAppBar = true;
          });
        }
      }
    });
    super.initState();
  }

  Widget _sizedBox({double? height, double? width}) =>
      SizedBox(height: height ?? 0, width: width ?? 0);

  Widget _divider() => Divider(color: Colors.grey.shade400, thickness: 1);

  Widget _headText(String? text) =>
      Text(text!, style: const TextStyle(fontSize: 14, color: Colors.grey));

  String? favoriteDocumentId;
  double kilograms = 0;
  String fraction = '';

  Future<void> addToFavorites() async {
    final newFavorite = favoritesCollection.doc();
    final querySnapshot = await favoritesCollection
        .where('productID', isEqualTo: widget.productID)
        .where('customerID', isEqualTo: authID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } else {
      final favoriteData = FavoriteModel(
          customerID: authID,
          favoriteID: newFavorite.id,
          productID: widget.productID);
      await newFavorite.set(favoriteData.toFirestore());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _showAppBar
          ? AppBar(elevation: 0, title: const Text('Product Details'))
          : null,
      body: SafeArea(
          child: StreamBuilder(
              stream: productsCollection
                  .where('productID', isEqualTo: widget.productID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return errorWidget(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingWidget();
                }
                if (snapshot.data!.docs.isEmpty) {
                  return emptyWidget('NO PRODUCTS FOUND');
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      List<ProductModel> productModel = snapshot.data!.docs
                          .map((doc) => ProductModel.fromFirestore(doc))
                          .toList();
                      var product = productModel[index];
                      return SingleChildScrollView(
                          child: Column(children: [
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                            imageUrl: product.imageURL,
                                            fit: BoxFit.cover))))),
                        Column(children: [
                          ListTile(
                              dense: true,
                              leading: const Icon(Icons.info),
                              title: Text(product.productName),
                              subtitle: Text(product.description)),
                          const Divider(height: 0, thickness: 1),
                          ListTile(
                              dense: true,
                              leading: const Icon(Icons.category),
                              title: Text(product.category),
                              subtitle: Text(product.description),
                              trailing: IconButton(
                                  icon: StreamBuilder(
                                      stream: favoritesCollection
                                          .where('productID',
                                              isEqualTo: widget.productID)
                                          .where('customerID',
                                              isEqualTo: authID)
                                          .snapshots(),
                                      builder: (context, fs) {
                                        if (fs.hasError) {
                                          return errorWidget(
                                              fs.error.toString());
                                        }
                                        if (fs.connectionState ==
                                            ConnectionState.waiting) {
                                          return loadingWidget();
                                        }
                                        if (fs.hasData) {
                                          List<FavoriteModel> favoriteModel = fs
                                              .data!.docs
                                              .map((doc) =>
                                                  FavoriteModel.fromFirestore(
                                                      doc))
                                              .toList();
                                          if (favoriteModel.isEmpty) {
                                            return const Icon(
                                                Icons.favorite_border,
                                                color: Colors.grey);
                                          } else {
                                            return const Icon(Icons.favorite,
                                                color: Colors.red);
                                          }
                                        }
                                        return const Icon(Icons.favorite_border,
                                            color: Colors.grey);
                                      }),
                                  onPressed: () => addToFavorites())),
                          const Divider(height: 0, thickness: 1),
                          ListTile(
                              dense: true,
                              leading: const Icon(Icons.payments),
                              title:
                                  Text('Regular Price (per ${product.unit})'),
                              trailing: Text(
                                  'P ${product.regularPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))),
                          const Divider(height: 0, thickness: 1),
                          ListTile(
                              dense: true,
                              leading: const Icon(Icons.delivery_dining),
                              title: const Text('Delivery Fee'),
                              trailing: Text(
                                  'P ${product.shippingCharge.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))),
                          const Divider(height: 0, thickness: 1),
                          FutureBuilder(
                              future: vendorsCollection
                                  .where('vendorID',
                                      isEqualTo: product.vendorID)
                                  .get(),
                              builder: (context, vSnapshot) {
                                if (vSnapshot.hasError) {
                                  return errorWidget(
                                      vSnapshot.error.toString());
                                }
                                if (vSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return loadingWidget();
                                }
                                if (vSnapshot.data!.docs.isNotEmpty) {
                                  var vendor = vSnapshot.data!.docs[0];
                                  return Column(children: [
                                    ListTile(
                                        dense: true,
                                        leading: SizedBox(
                                            height: 35,
                                            width: 35,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: Image.network(
                                                    vendor['logo']))),
                                        title: Text(vendor['businessName']),
                                        trailing: TextButton(
                                            onPressed: () => viewVendorDetails(
                                                vendor['vendorID']),
                                            child:
                                                const Text('Vendor Details'))),
                                    const Divider(height: 0, thickness: 1)
                                  ]);
                                }
                                return emptyWidget('VENDOR NOT FOUND');
                              }),
                          const SizedBox(height: 100)
                        ]),
                      ]));
                    });
              })),
      bottomSheet: ListTile(
          onTap: () async => showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => FutureBuilder(
                  future: productsCollection
                      .where('productID', isEqualTo: widget.productID)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return errorWidget(snapshot.error.toString());
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loadingWidget();
                    }
                    if (snapshot.hasData) {
                      var products = snapshot.data!.docs;
                      var product = products[0];
                      return StatefulBuilder(builder: (context, setState) {
                        double regularPrice =
                            product['regularPrice'].toDouble();
                        double finalPrice = regularPrice * kilograms;
                        return AlertDialog(
                            scrollable: true,
                            titlePadding: EdgeInsets.zero,
                            title: Card(
                                color: Colors.green.shade800,
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        topRight: Radius.circular(3))),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                      'P ${product['regularPrice'].toStringAsFixed(2)} per ${product['unit']}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ))),
                            content: Column(children: [
                              SizedBox(
                                  height: 150,
                                  child: DecimalNumberPicker(
                                      initialValue: kilograms,
                                      minValue: 0,
                                      maxValue: 1000,
                                      decimalPrecision: 2,
                                      otherItemsDecoration:
                                          BoxDecoration(boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            blurRadius: 20,
                                            spreadRadius: 0)
                                      ]),
                                      pickedItemDecoration:
                                          BoxDecoration(boxShadow: [
                                        BoxShadow(
                                            color: Colors.blue.withOpacity(.5),
                                            blurRadius: 20,
                                            spreadRadius: 0)
                                      ]),
                                      onChanged: (value) =>
                                          setState(() => kilograms = value))),
                              const Divider(thickness: 1),
                              decimalToFraction(
                                  kilograms, product['unit'].toString(), 15),
                              const Divider(thickness: 1),
                              const Text('TOTAL PAYMENT',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center),
                              Text('P ${numberToString(finalPrice)}',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)
                            ]),
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('CANCEL',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold))),
                              TextButton(
                                  onPressed: () async {
                                    final vendorIDStream = productsCollection
                                        .where('productID',
                                            isEqualTo: widget.productID)
                                        .snapshots();
                                    final vendorIDDocument =
                                        await vendorIDStream.first;
                                    final vendorID =
                                        vendorIDDocument.docs.first['vendorID'];
                                    addToCart(
                                        authID, widget.productID, vendorID);
                                  },
                                  child: const Text('CONFIRM',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)))
                            ]);
                      });
                    }
                    return emptyWidget('PRODUCT NOT FOUND');
                  })),
          tileColor: Colors.green.shade900,
          leading: const Icon(Icons.add_shopping_cart, color: Colors.white),
          title: const Text('Add to Cart',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.check, color: Colors.white)));

  addToCart(String? customerID, String productID, String vendorID) async {
    try {
      final checkVendorID =
          await cartsCollection.where('vendorID', isEqualTo: vendorID).get();
      final List<QueryDocumentSnapshot> documents = checkVendorID.docs;
      var checkedVendorID;
      for (final doc in documents) {
        final Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
        setState(() => checkedVendorID = data['vendorID']);
      }
      if (checkedVendorID == vendorID) {
        addToCartWithSameVendor(customerID, productID, vendorID);
      } else {
        final newCart = cartsCollection.doc();
        final cartData = CartModel(
            cartID: newCart.id,
            customerID: customerID,
            productIDs: [productID],
            vendorID: vendorID);
        await newCart.set(cartData.toFirestore()).then((value) => showDialog(
                context: context,
                builder: (builder) =>
                    successDialog(context, 'New product added to cart!'))
            .then((value) => Navigator.pop(context)));
      }
    } catch (e) {
      errorDialog(context, e.toString());
    }
  }

  addToCartWithSameVendor(
      String? customerID, String productID, String vendorID) async {
    try {
      cartsCollection
          .where('vendorID', isEqualTo: vendorID)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var cart in querySnapshot.docs) {
          late List<dynamic> productIDs;
          Map<String, dynamic>? cartData = cart.data() as Map<String, dynamic>?;
          if (cartData != null && cartData.containsKey('productIDs')) {
            productIDs = cartData['productIDs'] as List<dynamic>;
            // for (var productID in productIDs) {
            //   print(productID);
            // }
            productIDs.add(productID);
          }
          cartsCollection.doc(cart.id).update({
            'productIDs': productIDs,
          }).then((value) => showDialog(
                  context: context,
                  builder: (_) =>
                      successDialog(context, 'Product added to cart!'))
              .then((value) => Navigator.pop(context)));
        }
      });
    } catch (e) {
      errorDialog(context, e.toString());
    }
  }

  viewVendorDetails(String vendorID) => showDialog(
      context: context,
      builder: (_) => FutureBuilder(
          future:
              vendorsCollection.where('vendorID', isEqualTo: vendorID).get(),
          builder: (context, s) {
            if (s.hasError) {
              return errorWidget(s.error.toString());
            }
            if (s.connectionState == ConnectionState.waiting) {
              return loadingWidget();
            }
            if (s.data!.docs.isNotEmpty) {
              var vendor = s.data!.docs[0];
              return AlertDialog(
                  scrollable: true,
                  contentPadding: EdgeInsets.zero,
                  content: Column(children: [
                    SizedBox(
                        height: 150,
                        child: DrawerHeader(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            child:
                                Stack(alignment: Alignment.center, children: [
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
                                        height: 125,
                                        width: 125,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    vendor['logo']),
                                                fit: BoxFit.cover)))
                                  ])
                            ]))),
                    ListTile(
                        dense: true,
                        isThreeLine: true,
                        leading: const Icon(Icons.store),
                        title: Text(vendor['businessName'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
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
                        subtitle:
                            Text(dateTimeToString(vendor['registeredOn'])))
                  ]),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'))
                  ]);
            }
            return emptyWidget('VENDOR NOT FOUND');
          }));
}

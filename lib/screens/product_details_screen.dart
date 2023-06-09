import 'package:awesome_number_picker/awesome_number_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marketdo_app/models/cart_model.dart';
import 'package:marketdo_app/models/favorite_model.dart';
import 'package:marketdo_app/models/product_model.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/api_widgets.dart';

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
    final favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');
    final newFavorite = favoritesCollection.doc();
    final querySnapshot = await favoritesCollection
        .where('productID', isEqualTo: widget.productID)
        .where('customerID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } else {
      final favoriteData = FavoriteModel(
          customerID: FirebaseAuth.instance.currentUser!.uid,
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
              stream: FirebaseFirestore.instance
                  .collection('products')
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
                                        child:
                                            Image.network(product.imageURL))))),
                        Column(children: [
                          Text(product.productName,
                              style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          ListTile(
                              dense: true,
                              title: Text(product.category),
                              subtitle: Text(product.description),
                              trailing: IconButton(
                                  icon: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('favorites')
                                          .where('productID',
                                              isEqualTo: widget.productID)
                                          .where('customerID',
                                              isEqualTo: FirebaseAuth
                                                  .instance.currentUser!.uid)
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
                              title: const Text('Shipping Fee'),
                              trailing: Text(
                                  'P ${product.shippingCharge.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))),
                          const Divider(height: 0, thickness: 1),
                          FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('vendor')
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
                          // Row(children: [
                          //   Icon(IconlyBold.star,
                          //       color: Theme.of(context).primaryColor,
                          //       size: 14),
                          //   Icon(IconlyBold.star,
                          //       color: Theme.of(context).primaryColor,
                          //       size: 14),
                          //   Icon(IconlyBold.star,
                          //       color: Theme.of(context).primaryColor,
                          //       size: 14),
                          //   Icon(IconlyBold.star,
                          //       color: Theme.of(context).primaryColor,
                          //       size: 14),
                          //   Icon(IconlyBold.star,
                          //       color: Theme.of(context).primaryColor,
                          //       size: 14),
                          //   _sizedBox(width: 4),
                          //   const Text('(5)',
                          //       style: TextStyle(fontSize: 12))
                          // ]),
                          // _sizedBox(height: 10),
                          // if (product.size != 0)
                          //   Column(
                          //       crossAxisAlignment:
                          //           CrossAxisAlignment.start,
                          //       children: [
                          //         _sizedBox(height: 10),
                          //         _headText('Variations'),
                          // SizedBox(
                          //     height: 50,
                          //     child: ListView(
                          //         scrollDirection:
                          //             Axis.horizontal,
                          //         children: product.size
                          //             .map((e) {
                          //           return Padding(
                          //               padding:
                          //                   const EdgeInsets
                          //                       .all(8),
                          //               child:
                          //                   OutlinedButton(
                          //                       style:
                          //                           ButtonStyle(
                          //                         backgroundColor: MaterialStateProperty.all(_selectedSize == e
                          //                             ? Theme.of(context)
                          //                                 .primaryColor
                          //                             : Colors
                          //                                 .white),
                          //                       ),
                          //                       onPressed: () =>
                          //                           setState(() =>
                          //                               _selectedSize =
                          //                                   e),
                          //                       child: Text(
                          //                           e,
                          //                           style: TextStyle(
                          //                               color: _selectedSize == e
                          //                                   ? Colors.white
                          //                                   : Colors.black))));
                          //         }).toList()))
                          // ]),
                          // _divider(),
                          // InkWell(
                          //     onTap: () => showModalBottomSheet(
                          //         context: context,
                          //         builder: (context) => ProductBottomSheet(
                          //             productID: product.productID)),
                          //     child: Padding(
                          //         padding: const EdgeInsets.only(
                          //             top: 6, bottom: 6),
                          //         child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               _headText('Specifications'),
                          //               const Icon(IconlyLight.arrowRight2,
                          //                   size: 14)
                          //             ]))),
                          // _divider(),
                          // Row(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Expanded(
                          //           flex: 2, child: _headText('Delivery')),
                          //       Expanded(
                          //           flex: 3,
                          //           child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 InkWell(
                          //                     onTap: () {},
                          //                     child: StreamBuilder<
                          //                             DocumentSnapshot>(
                          //                         stream: FirebaseFirestore
                          //                             .instance
                          //                             .collection(
                          //                                 'customers')
                          //                             .doc(FirebaseAuth
                          //                                 .instance
                          //                                 .currentUser!
                          //                                 .uid)
                          //                             .snapshots(),
                          //                         builder:
                          //                             (context, snapshot) {
                          //                           if (snapshot.hasError) {
                          //                             return streamErrorWidget(
                          //                                 snapshot.error
                          //                                     .toString());
                          //                           }
                          //                           if (snapshot
                          //                                   .connectionState ==
                          //                               ConnectionState
                          //                                   .waiting) {
                          //                             return streamLoadingWidget();
                          //                           }
                          //                           String? address =
                          //                               snapshot.data?.get(
                          //                                   'address');
                          //                           return Row(
                          //                               mainAxisSize:
                          //                                   MainAxisSize
                          //                                       .min,
                          //                               children: [
                          //                                 Flexible(
                          //                                     child: Text(
                          //                                         address ??
                          //                                             'Delivery address not set',
                          //                                         maxLines:
                          //                                             2,
                          //                                         overflow:
                          //                                             TextOverflow
                          //                                                 .ellipsis,
                          //                                         style: TextStyle(
                          //                                             fontSize:
                          //                                                 14,
                          //                                             color: address != null
                          //                                                 ? Colors.black
                          //                                                 : Colors.red))),
                          //                                 Icon(
                          //                                     IconlyLight
                          //                                         .location,
                          //                                     size: 16,
                          //                                     color: address !=
                          //                                             null
                          //                                         ? Colors
                          //                                             .black
                          //                                         : Colors
                          //                                             .red)
                          //                               ]);
                          //                         })),
                          //                 _sizedBox(height: 6),
                          //                 const Text(
                          //                     'Home Delivery 1-2 day(s)',
                          //                     style:
                          //                         TextStyle(fontSize: 14)),
                          //                 Text(
                          //                     'Delivery charge: ${product.isShipCharged ? 'Rs.${product.isShipCharged}' : 'Free'}',
                          //                     style: const TextStyle(
                          //                         color: Colors.grey,
                          //                         fontSize: 14))
                          //               ]))
                          //     ]),
                          // _divider(),
                          // Row(
                          //     mainAxisAlignment:
                          //         MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       _headText('Rating and Review (10)'),
                          //       const Text('View all',
                          //           style: TextStyle(color: Colors.red))
                          //     ]),
                          // _sizedBox(height: 10),
                          // Row(
                          //     mainAxisAlignment:
                          //         MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       const Text('Elvie deligero - 11 Feb 2023',
                          //           style: TextStyle(
                          //               color: Colors.grey, fontSize: 12)),
                          //       Row(children: [
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyLight.star,
                          //             size: 12,
                          //             color: Theme.of(context).primaryColor)
                          //       ])
                          //     ]),
                          // const Text(
                          //     'Good product, good quality\nOn time delivery'),
                          // _sizedBox(height: 20),
                          // Row(
                          //     mainAxisAlignment:
                          //         MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       const Text('Elvie deligero - 11 Feb 2023',
                          //           style: TextStyle(
                          //               color: Colors.grey, fontSize: 12)),
                          //       Row(children: [
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyBold.star,
                          //             size: 12,
                          //             color:
                          //                 Theme.of(context).primaryColor),
                          //         Icon(IconlyLight.star,
                          //             size: 12,
                          //             color: Theme.of(context).primaryColor)
                          //       ])
                          //     ]),
                          // const Text(
                          //     'Good product, good quality. On time delivery'),
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
                  future: FirebaseFirestore.instance
                      .collection('products')
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
                                    final vendorIDStream = FirebaseFirestore
                                        .instance
                                        .collection('products')
                                        .where('productID',
                                            isEqualTo: widget.productID)
                                        .snapshots();
                                    final vendorIDDocument =
                                        await vendorIDStream.first;
                                    final vendorID =
                                        vendorIDDocument.docs.first['vendorID'];
                                    addToCart(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        widget.productID,
                                        vendorID);
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

  addToCart(String customerID, String productID, String vendorID) async {
    try {
      final checkVendorID = await FirebaseFirestore.instance
          .collection('carts')
          .where('vendorID', isEqualTo: vendorID)
          .get();
      final List<QueryDocumentSnapshot> documents = checkVendorID.docs;
      var checkedVendorID;
      for (final doc in documents) {
        final Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
        setState(() => checkedVendorID = data['vendorID']);
      }
      if (checkedVendorID == vendorID) {
        addToCartWithSameVendor(customerID, productID, vendorID);
      } else {
        final newCart = FirebaseFirestore.instance.collection('carts').doc();
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
      String customerID, String productID, String vendorID) async {
    try {
      FirebaseFirestore.instance
          .collection('carts')
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
          FirebaseFirestore.instance.collection('carts').doc(cart.id).update({
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

  Future<void> addToWishlist({
    context,
    required String productName,
    required List imageUrls,
    required double regularPrice,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('wishlist').add({
        'name': productName,
        'regularPrice': regularPrice,
        'imageUrls': imageUrls,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Product added to wishlist.'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add product to wishlist.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  viewVendorDetails(String vendorID) => showDialog(
      context: context,
      builder: (_) => FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('vendor')
              .where('vendorID', isEqualTo: vendorID)
              .get(),
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
                        isThreeLine: true,
                        leading: const Icon(Icons.numbers),
                        title: Text('PIN CODE: ${vendor['pinCode']}'),
                        subtitle: Text(
                            'TIN: ${vendor['tin']}\nTAX REGISTERED: ${vendor['isTaxRegistered'] == true ? 'YES' : 'NO'}')),
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

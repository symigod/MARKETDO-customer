import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marketdo_app/models/cart_model.dart';
import 'package:marketdo_app/models/product_model.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/product_bottom_sheet.dart';
import 'package:marketdo_app/widgets/stream_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productID;
  const ProductDetailScreen({super.key, required this.productID});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseService _service = FirebaseService();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
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

  // getSize() {
  //   if (widget.product!.size != null) {
  //     setState(() => _selectedSize = widget.product!.size![0]);
  //   }
  // }

  Widget _sizedBox({double? height, double? width}) =>
      SizedBox(height: height ?? 0, width: width ?? 0);

  Widget _divider() => Divider(color: Colors.grey.shade400, thickness: 1);

  Widget _headText(String? text) =>
      Text(text!, style: const TextStyle(fontSize: 14, color: Colors.grey));

  bool isFavorite = false;
  String? favoriteDocumentId;

  void addToFavorites() {
    CollectionReference favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');

    if (isFavorite) {
      favoritesCollection
          .doc(favoriteDocumentId)
          .delete()
          .then((value) => showDialog(
                  context: context,
                  builder: (_) =>
                      successDialog(context, 'Product removed from favorites!'))
              .then((value) => setState(() => isFavorite = false)))
          .catchError((error) => showDialog(
              context: context,
              builder: (_) => successDialog(
                  context, 'Failed to remove product from favorites: $error')));
    } else {
      favoritesCollection
          .add({
            'customerID': FirebaseAuth.instance.currentUser!.uid,
            'favoriteID': favoritesCollection.doc().get(),
            'productID': widget.productID,
          })
          .then((value) => showDialog(
                  context: context,
                  builder: (_) =>
                      successDialog(context, 'Product added to favorites!'))
              .then((value) => setState(() {
                    isFavorite = true;
                    favoriteDocumentId = value.id;
                  })))
          .catchError((error) => showDialog(
              context: context,
              builder: (_) => successDialog(
                  context, 'Failed to add product to favorites: $error')));
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
                  .collection('product')
                  .where('productID', isEqualTo: widget.productID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return streamErrorWidget(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return streamLoadingWidget();
                }
                if (snapshot.data!.docs.isEmpty) {
                  return streamEmptyWidget('NO PRODUCTS FOUND');
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      List<ProductModel> productModel = snapshot.data!.docs
                          .map((doc) => ProductModel.fromFirestore(doc))
                          .toList();
                      var product = productModel[index];
                      return SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const SizedBox(height: 50),
                            Center(
                              child: SizedBox(
                                  height: 300,
                                  child: Image.network(product.imageURL)
                                  // Stack(children: [
                                  //   Hero(
                                  //       tag: product.imageURL,
                                  //       child: PageView(
                                  //           onPageChanged: (value) => setState(
                                  //               () => pageNumber = value),
                                  //           children: widget.product!.imageUrls!
                                  //               .map((e) => CachedNetworkImage(
                                  //                   imageUrl: e))
                                  //               .toList())),
                                  //   Positioned(
                                  //       bottom: 10,
                                  //       right:
                                  //           MediaQuery.of(context).size.width / 2,
                                  //       child: CircleAvatar(
                                  //           radius: 14,
                                  //           backgroundColor: Colors.black26,
                                  //           child: Text(
                                  //               '${pageNumber! + 1}/${widget.product!.imageUrls!.length}',
                                  //               style: const TextStyle(
                                  //                   fontSize: 12))))
                                  // ])
                                  ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('₱ ${product.regularPrice}',
                                                style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 20)),
                                            Row(children: [
                                              IconButton(
                                                  icon: Icon(
                                                      isFavorite
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: isFavorite
                                                          ? Colors.red
                                                          : null),
                                                  onPressed: () =>
                                                      addToFavorites()),
                                              IconButton(
                                                splashRadius: 20,
                                                icon: const Icon(Icons.share,
                                                    size: 18,
                                                    color: Colors.grey),
                                                onPressed: () {},
                                              )
                                            ])
                                          ]),
                                      _sizedBox(height: 10),
                                      Text(product.productName),
                                      _sizedBox(height: 10),
                                      Row(children: [
                                        Icon(IconlyBold.star,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 14),
                                        Icon(IconlyBold.star,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 14),
                                        Icon(IconlyBold.star,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 14),
                                        Icon(IconlyBold.star,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 14),
                                        Icon(IconlyBold.star,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 14),
                                        _sizedBox(width: 4),
                                        const Text('(5)',
                                            style: TextStyle(fontSize: 12))
                                      ]),
                                      _sizedBox(height: 10),
                                      Text(product.description),
                                      if (product.size != 0)
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _sizedBox(height: 10),
                                              _headText('Variations'),
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
                                              //                       .all(8.0),
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
                                            ]),
                                      _divider(),
                                      InkWell(
                                          onTap: () => showModalBottomSheet(
                                              context: context,
                                              builder: (context) =>
                                                  ProductBottomSheet(
                                                      productID:
                                                          product.productID)),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 6, bottom: 6),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    _headText('Specifications'),
                                                    const Icon(
                                                        IconlyLight.arrowRight2,
                                                        size: 14)
                                                  ]))),
                                      _divider(),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: _headText('Delivery')),
                                            Expanded(
                                                flex: 3,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      InkWell(
                                                          onTap: () {},
                                                          child: StreamBuilder<
                                                                  DocumentSnapshot>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'customers')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                    .hasError) {
                                                                  return streamErrorWidget(
                                                                      snapshot
                                                                          .error
                                                                          .toString());
                                                                }
                                                                if (snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting) {
                                                                  return streamLoadingWidget();
                                                                }
                                                                String?
                                                                    address =
                                                                    snapshot
                                                                        .data
                                                                        ?.get(
                                                                            'address');
                                                                return Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Flexible(
                                                                          child: Text(
                                                                              address ?? 'Delivery address not set',
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(fontSize: 14, color: address != null ? Colors.black : Colors.red))),
                                                                      Icon(
                                                                          IconlyLight
                                                                              .location,
                                                                          size:
                                                                              16,
                                                                          color: address != null
                                                                              ? Colors.black
                                                                              : Colors.red)
                                                                    ]);
                                                              })),
                                                      _sizedBox(height: 6),
                                                      const Text(
                                                          'Home Delivery 1-2 day(s)',
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                      Text(
                                                          'Delivery charge: ${product.isShipCharged ? 'Rs.${product.isShipCharged}' : 'Free'}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 14))
                                                    ]))
                                          ]),
                                      _divider(),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _headText('Rating and Review (10)'),
                                            const Text('View all',
                                                style: TextStyle(
                                                    color: Colors.red))
                                          ]),
                                      _sizedBox(height: 10),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                                'Elvie deligero - 11 Feb 2023',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Row(children: [
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyLight.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor)
                                            ])
                                          ]),
                                      const Text(
                                          'Good product, good quality\nOn time delivery'),
                                      _sizedBox(height: 20),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                                'Elvie deligero - 11 Feb 2023',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Row(children: [
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyBold.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              Icon(IconlyLight.star,
                                                  size: 12,
                                                  color: Theme.of(context)
                                                      .primaryColor)
                                            ])
                                          ]),
                                      const Text(
                                          'Good product, good quality. On time delivery'),
                                      _sizedBox(height: 100)
                                    ]))
                          ]));
                    });
              })),
      bottomSheet: ListTile(
          onTap: () async {
            final vendorIDStream = FirebaseFirestore.instance
                .collection('product')
                .where('productID', isEqualTo: widget.productID)
                .snapshots();
            final vendorIDDocument = await vendorIDStream.first;
            final vendorID = vendorIDDocument.docs.first['vendorID'];
            addToCart(FirebaseAuth.instance.currentUser!.uid, widget.productID,
                vendorID);
          },
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
          vendorID: vendorID,
        );
        await newCart.set(cartData.toFirestore()).then((value) => showDialog(
            context: context,
            builder: (builder) =>
                successDialog(context, 'New product added to cart!')));
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
                  successDialog(context, 'Product added to cart!')));
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
}

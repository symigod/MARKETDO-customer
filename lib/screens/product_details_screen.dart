import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marketdo_app/firebase_services.dart';
import 'package:marketdo_app/main.dart';
import 'package:marketdo_app/models/cart_model.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/product_bottom_sheet.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final String? productId;
   final String? productName;
  final String? description;
  const ProductDetailScreen({this.productName, this.description, this.product, this.productId, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _service = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final store = GetStorage();
  ScrollController? _scrollController;
  int? pageNumber = 0;
  bool _isScrollDown = false;
  bool _showAppBar = true;
  String? _selectedSize;


  @override
  void initState() {
    getSize();
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

  getSize() {
    if (widget.product!.size != null) {
      setState(() {
        _selectedSize = widget.product!.size![0];
      });
    }
  }

  Widget _sizedBox({double? height, double? width}) {
    return SizedBox(
      height: height ?? 0,
      width: width ?? 0,
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey.shade400,
      thickness: 1,
    );
  }

  Widget _headText(String? text) {
    return Text(
      text!,
      style: TextStyle(fontSize: 14, color: Colors.grey),
    );
  }

  //FAVORITES
  bool isFavorite = false;
  String? favoriteDocumentId; // Store the document ID of the favorite product

  void addToFavorites() {
    // Get a reference to the "favorites" collection in Firestore
    CollectionReference favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');

    // Check if the product is already favorited
    if (isFavorite) {
      // Unfavorite the product
      favoritesCollection
          .doc(favoriteDocumentId)
          .delete()
          .then((value) {
        print('Product removed from favorites!');
        setState(() {
          isFavorite = false;
        });
      }).catchError((error) {
        print('Failed to remove product from favorites: $error');
      });
    } else {
      // Add the product data to the "favorites" collection
      favoritesCollection
          .add({
            'imageUrls': widget.product!.imageUrls![0],
            'productName': widget.product!.productName,
            'description': widget.product!.description,
            'regularPrice': widget.product!.regularPrice,
           
          })
          .then((value) {
            print('Product added to favorites!');
            setState(() {
              isFavorite = true;
              favoriteDocumentId = value.id;
            });
          })
          .catchError((error) {
            print('Failed to add product to favorites: $error');
          });
    }
  }

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.grey),
              actions: [
                _sizedBox(width: 10),
              ],
            )
          : null,
      //IT WILL SHOW APP ONLY IF WE SCROLL DOWN
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.product!.imageUrls![0],
                      child: PageView(
                        onPageChanged: (value) {
                          setState(() {
                            pageNumber = value;
                          });
                        },
                        children: widget.product!.imageUrls!.map((e) {
                          return CachedNetworkImage(
                            imageUrl: e,
                            // fit: BoxFit.cover
                          );
                        }).toList(),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: MediaQuery.of(context).size.width / 2,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black26,
                        child: Text(
                          '${pageNumber! + 1}/${widget.product!.imageUrls!.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱ ${_service.formattedNumber(widget.product!.regularPrice!)}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                              onPressed: () {
                                addToFavorites();
                              },
                            ),
                        

                            IconButton(
                              splashRadius: 20,
                              icon: Icon(Icons.share,
                                  size: 18, color: Colors.grey),
                              onPressed: () {
                                
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    _sizedBox(height: 10),
                    Text(widget.product!.productName),
                    _sizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          IconlyBold.star,
                          color: Theme.of(context).primaryColor,
                          size: 14,
                        ),
                        Icon(
                          IconlyBold.star,
                          color: Theme.of(context).primaryColor,
                          size: 14,
                        ),
                        Icon(
                          IconlyBold.star,
                          color: Theme.of(context).primaryColor,
                          size: 14,
                        ),
                        Icon(
                          IconlyBold.star,
                          color: Theme.of(context).primaryColor,
                          size: 14,
                        ),
                        Icon(
                          IconlyBold.star,
                          color: Theme.of(context).primaryColor,
                          size: 14,
                        ),
                        _sizedBox(width: 4),
                        const Text(
                          '(5)',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                    _sizedBox(height: 10),
                    Text(widget.product!.description!),
                    if (widget.product!.size != null &&
                        widget.product!.size!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sizedBox(height: 10),
                          _headText('Variations'),
                          SizedBox(
                            height: 50,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: widget.product!.size!.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _selectedSize == e
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.white),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedSize = e;
                                      });
                                    },
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                          color: _selectedSize == e
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    _divider(),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              //creating a different widget for this container
                              return ProductBottomSheet(
                                product: widget.product,
                              );
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          bottom: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _headText('Specifications'),
                            Icon(
                              IconlyLight.arrowRight2,
                              size: 14,
                            )
                          ],
                        ),
                      ),
                    ),
                    _divider(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _headText('Delivery')),
                        Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Handle the tap event here, e.g., navigate to address selection screen
                                  },
                                  child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('customer')
                                        .doc(_auth.currentUser!.uid)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text('Loading...');
                                      }

                                      String? address = snapshot.data?.get('address');
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              address ?? 'Delivery address not set',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: address != null ? Colors.black : Colors.red,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            IconlyLight.location,
                                            size: 16,
                                            color: address != null ? Colors.black : Colors.red,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                                _sizedBox(height: 6),
                                const Text(
                                  'Home Delivery 1-2 day(s)',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Delivery charge: ${widget.product!.chargeShipping! ? 'Rs.${widget.product!.shippingCharge!}' : 'Free'}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                )
                              ],
                            )),
                      ],
                    ),
                    _divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _headText('Rating and Review (10)'),
                        Text(
                          'View all',
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                    _sizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Elvie deligero - 11 Feb 2023',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Row(
                          children: [
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyLight.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Text('Good product, good quality\nOn time delivery'),
                    _sizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Elvie deligero - 11 Feb 2023',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Row(
                          children: [
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              IconlyLight.star,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Text('Good product, good quality. On time delivery'),
                    _sizedBox(height: 20),
                    
                  
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                color: Colors.grey[800],
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        addToCart(
                          sellerName: widget.product!.seller!['name'],
                          productName: widget.product!.productName,
                          imageUrls: widget.product!.imageUrls!,
                          regularPrice: widget.product!.regularPrice!,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.bookmark,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart(
      {required String sellerName,
      required String productName,
      required List imageUrls,
      required double regularPrice,
      required}) async {
    try {
      String cardID = generateID();
      // await _firestore.collection('carts').add({
      //   'seller': seller,
      //   'productName': productName,
      //   'imageUrls': imageUrls,
      //   'regularPrice': regularPrice,
      // });

      // kini gamita nga add/create function
      final newCart = _firestore.collection('carts').doc(cardID);
      final cartData = CartModel(
          id: cardID,
          imageUrls: imageUrls,
          productName: productName,
          regularPrice: regularPrice,
          sellerName: sellerName);
      await newCart.set(cartData.toJson()).then((value) => showDialog(
          context: context,
          builder: (builder) =>
              successDialog(context, 'Product added successfully!')));
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> addToWishlist({
    required String productName,
    required List imageUrls,
    required double regularPrice,
  }) async {
    try {
      // Get a reference to the Firebase collection named 'wishlist'
      await _firestore.collection('wishlist').add({
        // Add the product to the collection with a document ID equal to the product ID
        'name': productName,
        'regularPrice': regularPrice,
        'imageUrls': imageUrls,
      });

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product added to wishlist.'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add product to wishlist.'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}

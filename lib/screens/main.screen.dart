import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/main.dart';
import 'package:marketdo_app/screens/authentication/login.dart';
import 'package:marketdo_app/screens/orders/cart.dart';
import 'package:marketdo_app/screens/favorites.dart';
import 'package:marketdo_app/screens/home.dart';
import 'package:marketdo_app/screens/orders/main.orders.dart';
import 'package:marketdo_app/widgets/drawer.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class MainScreen extends StatefulWidget {
  final int? index;
  const MainScreen({this.index, Key? key}) : super(key: key);
  static const String id = 'home-screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    checkCustomerInDB();
    if (widget.index != null) {
      setState(() => _selectedIndex = widget.index!);
    }
    super.initState();
  }

  Future<void> checkCustomerInDB() async {
    if (authID != null) {
      await customersCollection
          .doc(authID)
          .get()
          .then((customer) => customer.exists
              ? null
              : FirebaseAuth.instance.currentUser == null
                  ? Timer(
                      const Duration(microseconds: 1),
                      () => Navigator.pushReplacementNamed(
                          context, LoginScreen.id))
                  : updateCustomerOnlineStatus(authID, true))
          .catchError((error) => print('Failed to retrieve document: $error'));
    }
  }

  final List<Widget> _widgetOptions = const [
    HomeScreen(),
    // CategoryScreen(),
    CartScreen(),
    OrderScreen(),
    FavoritesScreen()
  ];

  @override
  Widget build(BuildContext context) => FirebaseAuth.instance.currentUser ==
          null
      ? loadingWidget()
      : SafeArea(
          child: StreamBuilder(
              stream: customersCollection
                  .where('customerID', isEqualTo: authID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return errorWidget(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingWidget();
                }
                if (snapshot.hasData) {
                  return Scaffold(
                      key: _scaffoldKey,
                      appBar: AppBar(
                          automaticallyImplyLeading: false,
                          elevation: 0,
                          title: ListTile(
                              title: const Text('Welcome to MarketDo',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${snapshot.data!.docs[0]['name']}!',
                                  style: const TextStyle(color: Colors.white))),
                          bottom: PreferredSize(
                              preferredSize:
                                  Size(MediaQuery.of(context).size.width, 60),
                              child: const SearchWidget()),
                          actions: [
                            GestureDetector(
                                onTap: () =>
                                    _scaffoldKey.currentState?.openEndDrawer(),
                                child: Container(
                                    height: 50,
                                    width: 50,
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                snapshot.data!.docs[0]['logo']),
                                            fit: BoxFit.cover))))
                          ]),
                      endDrawer: const CustomDrawer(),
                      floatingActionButton:
                          const Padding(padding: EdgeInsets.only(bottom: 45)),
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerDocked,
                      body: Center(
                          child: _widgetOptions.elementAt(_selectedIndex)),
                      bottomNavigationBar: BottomNavigationBar(
                          backgroundColor: Colors.green.shade900,
                          elevation: 4,
                          items: [
                            const BottomNavigationBarItem(
                                icon: Icon(Icons.home), label: 'Home'),
                            // const BottomNavigationBarItem(
                            //     icon: Icon(Icons.category),
                            //     label: 'Categories'),
                            BottomNavigationBarItem(
                                icon: Stack(children: [
                                  const Icon(Icons.shopping_cart),
                                  StreamBuilder(
                                      stream: cartsCollection
                                          .where('customerID',
                                              isEqualTo: authID)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return errorWidget(
                                              snapshot.error.toString());
                                        }
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container());
                                        }
                                        return Positioned(
                                            right: 0,
                                            top: 0,
                                            child: snapshot.data!.docs.isEmpty
                                                ? Container()
                                                : Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.red,
                                                            shape: BoxShape
                                                                .circle),
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 12,
                                                            minHeight: 12),
                                                    child: Text(
                                                        snapshot
                                                            .data!.docs.length
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center)));
                                      })
                                ]),
                                label: 'Cart'),
                            BottomNavigationBarItem(
                                icon: Stack(children: [
                                  const Icon(Icons.shopping_bag),
                                  StreamBuilder(
                                      stream: ordersCollection
                                          .where('customerID',
                                              isEqualTo: authID)
                                          .where('isPending', isEqualTo: true)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return errorWidget(
                                              snapshot.error.toString());
                                        }
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container());
                                        }
                                        return Positioned(
                                            right: 0,
                                            top: 0,
                                            child: snapshot.data!.docs.isEmpty
                                                ? Container()
                                                : Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.red,
                                                            shape: BoxShape
                                                                .circle),
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 12,
                                                            minHeight: 12),
                                                    child: Text(
                                                        snapshot
                                                            .data!.docs.length
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center)));
                                      })
                                ]),
                                label: 'Orders'),
                            const BottomNavigationBarItem(
                                icon: Icon(Icons.favorite), label: 'Favorites')
                          ],
                          currentIndex: _selectedIndex,
                          showUnselectedLabels: true,
                          selectedItemColor: Colors.yellow,
                          unselectedItemColor: Colors.white,
                          onTap: (int index) =>
                              setState(() => _selectedIndex = index),
                          type: BottomNavigationBarType.fixed));
                }
                // Timer(
                //     const Duration(microseconds: 1),
                //     () => Navigator.pushReplacementNamed(
                //         context, LoginScreen.id));
                return loadingWidget();
              }));
}

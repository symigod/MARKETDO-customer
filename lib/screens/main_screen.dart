import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/screens/cart_screen.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:marketdo_app/screens/category_screen.dart';
import 'account_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  final int? index;
  const MainScreen({this.index, Key? key}) : super(key: key);
  static const String id = 'HomeScreen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = const [
    HomeScreen(),
    CategoryScreen(),
    // MessageScreen(),
    CartScreen(),
    AccountScreen()
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    if (widget.index != null) {
      setState(() => _selectedIndex = widget.index!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: const Padding(padding: EdgeInsets.only(bottom: 45)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.green.shade900,
          elevation: 4,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                    _selectedIndex == 0 ? Icons.home : Icons.home_outlined),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 1
                    ? IconlyBold.category
                    : IconlyLight.category),
                label: 'Categories'),
            BottomNavigationBarItem(
                icon: Stack(children: [
                  Icon(_selectedIndex == 2 ? IconlyBold.buy : IconlyLight.buy),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('carts')
                          .where('customerID',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Positioned(
                              right: 0, top: 0, child: Container());
                        }
                        return Positioned(
                            right: 0,
                            top: 0,
                            child: snapshot.data!.docs.isEmpty
                                ? Container()
                                : Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    constraints: const BoxConstraints(
                                        minWidth: 12, minHeight: 12),
                                    child: Text(
                                        snapshot.data!.docs.length.toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center)));
                      })
                ]),
                label: 'Cart'),
            BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 3
                    ? CupertinoIcons.person_solid
                    : CupertinoIcons.person),
                label: 'Account')
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.yellow,
          showUnselectedLabels: true,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12));
}

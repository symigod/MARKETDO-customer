import 'package:flutter/material.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/screens/orders/cart.dart';
import 'package:marketdo_app/screens/categories/main.categories.dart';
import 'package:marketdo_app/screens/favorites.dart';
import 'package:marketdo_app/screens/home.dart';
import 'package:marketdo_app/screens/orders/main.orders.dart';
import 'package:marketdo_app/widgets/drawer.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

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
    OrderScreen(),
    FavoritesScreen()
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  void initState() {
    if (widget.index != null) {
      setState(() => _selectedIndex = widget.index!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
          appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: const FittedBox(
                  child: Text('MarketDo App',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 2))),
              actions: [
                IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => errorDialog(
                            context, 'This feature will be available soon!')),
                    icon: const Icon(Icons.notifications, color: Colors.white))
              ]),
          drawer: const CustomDrawer(),
          floatingActionButton:
              const Padding(padding: EdgeInsets.only(bottom: 45)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
          bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.green.shade900,
              elevation: 4,
              items: [
                const BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Home'),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.category), label: 'Categories'),
                BottomNavigationBarItem(
                    icon: Stack(children: [
                      const Icon(Icons.shopping_cart),
                      StreamBuilder(
                          stream: cartsCollection
                              .where('customerID', isEqualTo: authID)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return errorWidget(snapshot.error.toString());
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
                                            snapshot.data!.docs.length
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center)));
                          })
                    ]),
                    label: 'Cart'),
                BottomNavigationBarItem(
                    icon: Stack(children: [
                      const Icon(Icons.shopping_bag),
                      StreamBuilder(
                          stream: ordersCollection
                              .where('customerID', isEqualTo: authID)
                              .where('isPending', isEqualTo: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return errorWidget(snapshot.error.toString());
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
                                            snapshot.data!.docs.length
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center)));
                          })
                    ]),
                    label: 'Orders'),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Favorites')
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.yellow,
              showUnselectedLabels: true,
              unselectedItemColor: Colors.white,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed)));
}

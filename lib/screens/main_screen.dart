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

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CategoryScreen(),
    // MessageScreen(),
    CartScreen(),
    AccountScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    if(widget.index!=null){
      setState(() {
        _selectedIndex = widget.index!;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 45),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
     body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: BottomNavigationBar(
          elevation: 4,
          items:  <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: 'Home',
              // backgroundColor: Colors.greenAccent,
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1 ? IconlyBold.category : IconlyLight.category),
              label: 'Categories',
              // backgroundColor: Colors.greenAccent,
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(_selectedIndex == 2 ? IconlyBold.chat : IconlyLight.chat),
            //   label: 'Messages',
            //   // backgroundColor: Colors.purpleAccent,
            // ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 3 ? IconlyBold.buy : IconlyLight.buy),
              label: 'Cart',
              // backgroundColor: Colors.greenAccent,
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 4 ? CupertinoIcons.person_solid : CupertinoIcons.person),
              label: 'Account',
              // backgroundColor: Colors.purpleAccent,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.greenAccent,
          showUnselectedLabels: true,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
        ),
      ),
    );
  }
}

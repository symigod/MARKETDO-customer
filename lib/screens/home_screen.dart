import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:marketdo_app/screens/search_screen.dart';
import 'package:marketdo_app/widgets/banner_widget.dart';
import 'package:marketdo_app/widgets/category/category_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      // backgroundColor: Colors.purple.shade200,
      backgroundColor: Colors.green,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: AppBar(
            automaticallyImplyLeading: false,
            // backgroundColor: Colors.purple.shade200,
            backgroundColor: Colors.green,
            elevation: 0,
            centerTitle: true,
            title:
                const Text('Marketdo App', style: TextStyle(letterSpacing: 2)),
            /* actions: [
                IconButton(
                    icon: const Icon(IconlyLight.buy),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const CartScreen())))
              ] */
          )),
      body: ListView(children: const [
        SearchWidget(),
        SizedBox(height: 10),
        BannerWidget(),
        CategoryWidget()
      ]));
}

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: 55,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                          hintText: 'Search in Marketdo App',
                          hintStyle: const TextStyle(color: Colors.grey),
                          suffixIcon: GestureDetector(
                              onTap: () => _search.text.isEmpty
                                  ? null
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              SearchScreen(
                                                  searchText: _search.text))),
                              child: const Icon(Icons.search,
                                  size: 20, color: Colors.grey))))))),
      SizedBox(
          child: SizedBox(
              height: 20,
              width: MediaQuery.of(context).size.width,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(children: [
                      Icon(IconlyLight.infoSquare, size: 12),
                      Text('100% Genuine',
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ]),
                    Row(children: [
                      Icon(IconlyLight.infoSquare, size: 12),
                      Text('2 - 3 days return',
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ]),
                    Row(children: [
                      Icon(IconlyLight.infoSquare, size: 12),
                      Text('Trusted Products',
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ])
                  ])))
    ]);
  }
}

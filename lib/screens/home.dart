import 'package:flutter/material.dart';
import 'package:marketdo_app/screens/products/main.products.dart';
import 'package:marketdo_app/screens/search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => const Scaffold(body: ProductsScreen());

  // Widget homeWidget() => ListView(children: const [
  //       // SearchWidget(),
  //       // BannerWidget(),
  //       HomeProductList()
  //     ]);
}

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _search = TextEditingController();

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(
            height: 55,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: TextField(
                        controller: _search,
                        onSubmitted: (value) => search(),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.fromLTRB(8, 5, 8, 0),
                            hintText: 'Search product...',
                            suffixIcon: GestureDetector(
                                onTap: () => search(),
                                child: const Icon(Icons.search, size: 20)))))))
      ]);

  search() => _search.text.isEmpty
      ? null
      : Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SearchScreen(searchText: _search.text)))
          .then((value) => _search.text = '');
}

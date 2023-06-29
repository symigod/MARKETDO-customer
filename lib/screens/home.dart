import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:marketdo_app/screens/categories/widget.categories.dart';
import 'package:marketdo_app/screens/search.dart';
import 'package:marketdo_app/widgets/banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) =>
      Scaffold(backgroundColor: Colors.green, body: homeWidget());

  Widget homeWidget() => ListView(children: const [
        SearchWidget(),
        SizedBox(height: 10),
        BannerWidget(),
        CategoryWidget()
      ]);
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
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TextField(
                        controller: _search,
                        onSubmitted: (value) => search(),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.fromLTRB(8, 5, 8, 0),
                            hintText: 'Search in Marketdo App',
                            suffixIcon: GestureDetector(
                                onTap: () => search(),
                                child: const Icon(Icons.search, size: 20))))))),
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

  search() => _search.text.isEmpty
      ? null
      : Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SearchScreen(searchText: _search.text.toUpperCase())))
          .then((value) => _search.text = '');
}

import 'package:flutter/material.dart';
import 'package:marketdo_app/models/product_model2.dart';

class SearchScreen extends StatefulWidget {
  final String searchText;
  const SearchScreen({super.key, required this.searchText});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: StreamBuilder(
          stream: searchProduct(widget.searchText),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('AN ERROR OCCURED\n${snapshot.error}'));
            } else

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                      'NO SEARCH RESULTS FOUND FOR\n"${widget.searchText}"',
                      textAlign: TextAlign.center));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                var approved = snapshot.data![index].approved;
                var brand = snapshot.data![index].brand;
                var category = snapshot.data![index].category;
                var chargeShipping = snapshot.data![index].chargeShipping;
                var description = snapshot.data![index].description;
                var imageUrls = snapshot.data![index].imageUrls;
                var mainCategory = snapshot.data![index].mainCategory;
                var manageInventory = snapshot.data![index].manageInventory;
                var otherDetails = snapshot.data![index].otherDetails;
                var productName = snapshot.data![index].productName;
                var regularPrice = snapshot.data![index].regularPrice;
                var seller = snapshot.data![index].seller;
                var shippingCharge = snapshot.data![index].shippingCharge;
                var size = snapshot.data![index].size;
                var soh = snapshot.data![index].soh;
                var unit = snapshot.data![index].unit;

                print('IMAGE URLS: ${imageUrls![0]}');
                return ListTile(
                  leading: Image.network(imageUrls[0]),
                  title: Text(productName),
                  subtitle: Text('Price: $regularPrice'),
                );
              },
            );
          }),
    );
  }
}

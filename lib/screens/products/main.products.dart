import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marketdo_app/screens/categories/clothing.dart';
import 'package:marketdo_app/screens/categories/food.dart';
import 'package:marketdo_app/screens/categories/household.dart';
import 'package:marketdo_app/screens/categories/others.dart';
import 'package:marketdo_app/screens/categories/personalcare.dart';
import 'package:marketdo_app/screens/categories/school.office.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 6,
      child: Scaffold(
          appBar: AppBar(
              toolbarHeight: 0,
              bottom: TabBar(
                  controller: tabController,
                  isScrollable: true,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.yellow,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(icon: FaIcon(FontAwesomeIcons.shirt)),
                    Tab(icon: FaIcon(FontAwesomeIcons.utensils)),
                    Tab(icon: FaIcon(FontAwesomeIcons.couch)),
                    Tab(icon: FaIcon(FontAwesomeIcons.handSparkles)),
                    Tab(icon: FaIcon(FontAwesomeIcons.folderOpen)),
                    Tab(icon: FaIcon(FontAwesomeIcons.ellipsis))
                  ])),
          body: TabBarView(controller: tabController, children: const [
            ClothingAndAccessories(),
            FoodAndBeverages(),
            HouseholdItems(),
            PersonalCare(),
            SchoolAndOfficeSupplies(),
            Others()
          ])));
}

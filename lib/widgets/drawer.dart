import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketdo_app/firebase.services.dart';
import 'package:marketdo_app/models/customer.model.dart';
import 'package:marketdo_app/screens/authentication/login.dart';
import 'package:marketdo_app/widgets/dialogs.dart';
import 'package:marketdo_app/widgets/snapshots.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Future<CustomerModel> fetchData() async {
    DocumentSnapshot snapshot = await customersCollection.doc(authID).get();
    return CustomerModel.fromFirestore(snapshot);
  }

  @override
  Widget build(BuildContext context) {
    Widget _menu({String? menuTitle, IconData? icon, String? route}) {
      return ListTile(
          leading: Icon(icon),
          title: Text(menuTitle!),
          onTap: () => Navigator.pushReplacementNamed(context, route!));
    }

    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorWidget(snapshot.error.toString());
          }
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return streamLoadingWidget();
          // }
          if (snapshot.hasData) {
            var customer = snapshot.data!;
            Timestamp timestamp = customer.registeredOn;
            DateTime dateTime = timestamp.toDate();
            String registeredOn =
                DateFormat('MMM dd, yyyy').format(dateTime).toString();
            return Drawer(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(children: [
                    SizedBox(
                        height: 150,
                        child: DrawerHeader(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              Container(
                                  padding: const EdgeInsets.all(20),
                                  height: 150,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              NetworkImage(customer.coverPhoto),
                                          fit: BoxFit.cover))),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                        height: 125,
                                        width: 125,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                            image: DecorationImage(
                                                image:
                                                    NetworkImage(customer.logo),
                                                fit: BoxFit.cover)))
                                  ])
                            ]))),
                    ListTile(
                        dense: true,
                        isThreeLine: true,
                        leading: const Icon(Icons.person),
                        title: Text(customer.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Customer ID: ${customer.customerID}')),
                    ListTile(
                        dense: true,
                        leading: const Icon(Icons.perm_phone_msg),
                        title: Text(customer.mobile),
                        subtitle: Text(customer.email)),
                    ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on),
                        title: Text(customer.address),
                        subtitle: Text(customer.landMark)),
                    ListTile(
                        dense: true,
                        leading: const Icon(Icons.date_range),
                        title: const Text('REGISTERED ON:'),
                        subtitle: Text(registeredOn))
                  ]))),
                  // _menu(menuTitle: 'Home', icon: Icons.home_outlined, route: HomeScreen.id),
                  // ExpansionTile(
                  //     leading: const Icon(Icons.weekend_outlined),
                  //     title: const Text('Products'),
                  //     children: [
                  //       _menu(menuTitle: 'All products', route: ProductScreen.id),
                  //       _menu(menuTitle: 'Add products', route: AddProductScreen.id),
                  //     ]),
                  // _menu(
                  //     menuTitle: 'Orders',
                  //     icon: Icons.shopping_cart_checkout_outlined,
                  //     route: OrderScreen.id),
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ListTile(
                        onTap: () => showDialog(
                            context: context,
                            builder: (_) => confirmDialog(context, 'LOGOUT',
                                    'Do you want to continue?', () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacementNamed(
                                      context, LoginScreen.id);
                                })),
                        dense: true,
                        tileColor: Colors.red,
                        title: const Text('Logout MarketDo App',
                            style: TextStyle(color: Colors.white)),
                        trailing:
                            const Icon(Icons.exit_to_app, color: Colors.white))
                  ])
                ]));
          }
          return emptyWidget('VENDOR NOT FOUND');
        });
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketdo_app/screens/favorite_screen.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userId;
  int numOrders = 0;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
    fetchOrderCount();
  }

  Future<void> fetchOrderCount() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('customerID', isEqualTo: _userId)
          .get();

      setState(() => numOrders = snapshot.size);
    } catch (error) {
      print('Error fetching order count: $error');
    }
  }

  Stream orderStream() => FirebaseFirestore.instance
      .collection('orders')
      .where('customerID', isEqualTo: _userId)
      .snapshots();

  Stream favoriteStream() => FirebaseFirestore.instance
      .collection('favorites')
      .where('customerID', isEqualTo: _userId)
      .snapshots();

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('My Account'), actions: [
        IconButton(
            icon: const Icon(Icons.exit_to_app), onPressed: () => logout())
      ]),
      body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('customers')
                  .doc(_userId)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;

                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView(children: [
                      Stack(alignment: Alignment.center, children: [
                        Container(
                            padding: const EdgeInsets.all(20),
                            height: 125,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(userData['coverPhoto']),
                                    fit: BoxFit.cover))),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      image: DecorationImage(
                                          image: NetworkImage(userData['logo']),
                                          fit: BoxFit.cover)))
                            ])
                      ]),
                      ListTile(
                          leading: const SizedBox(
                              height: 50,
                              width: 50,
                              child: Center(child: Icon(Icons.person))),
                          title: Text(userData['name']),
                          subtitle: Text(userData['approved'] == true
                              ? 'STATUS: APPROVED'
                              : 'STATUS NOT APPROVED')),
                      ListTile(
                          leading: const SizedBox(
                              height: 50,
                              width: 50,
                              child: Center(child: Icon(Icons.perm_phone_msg))),
                          title: Text(userData['mobile']),
                          subtitle: Text(userData['email'])),
                      ListTile(
                          leading: const SizedBox(
                              height: 50,
                              width: 50,
                              child: Center(child: Icon(Icons.location_on))),
                          title: Text(userData['address']),
                          subtitle: Text(userData['landMark'])),
                      const Divider(),
                      StreamBuilder(
                          stream: orderStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return ListTile(
                                leading: const Icon(Icons.shopping_cart),
                                title: Text(
                                    'My Orders (${snapshot.data!.docs.length})'),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 15),
                                onTap:
                                    () {} /* => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            OrderScreen(
                                                stream: orderStream()))) */
                                );
                          }),
                      StreamBuilder(
                          stream: favoriteStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return ListTile(
                                leading: const Icon(Icons.favorite),
                                title: Text(
                                    'My Favorites (${snapshot.data!.docs.length})'),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 15),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => FavoritesScreen(
                                            stream: favoriteStream()))));
                          })
                    ]));
              })));

  logout() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('LOGOUT'),
                content: const Text('Do you want to continue?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('NO',
                          style: TextStyle(color: Colors.red))),
                  TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, LoginScreen.id);
                      },
                      child: Text('YES',
                          style: TextStyle(color: Colors.green.shade900)))
                ]));
  }
}



// class AccountScreen extends StatelessWidget {

// const AccountScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text('My Account'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacementNamed(context, LoginScreen.id);
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children:  [
//                 const Text(
//                   '',
//                   style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold
                  
//                   ),
//                 ),
//                 const Padding(
//                   padding:  EdgeInsets.all(8.0),
//                   child:  Text(
//                     '',
//                     style: TextStyle(fontSize: 13.0, 
//                     ),
                    
//                   ),
//                 ),
//                 ElevatedButton(
//                   child: const Text('Edit Profile'),
//                   onPressed: () {
//                     // Handle edit profile here
//                   },
//                 ), 
//               ],
//             ),
//           ),
//           const Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Divider(
//               color: Colors.black12,
//                      ),
//            ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: SizedBox(
//                         height: 70,
//                         width: 100,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: const [
//                             Center(
//                               child: Text(
//                                 'Total Orders',
//                                 style: TextStyle(fontSize: 13.0),
//                               ),
//                             ),
//                             SizedBox(height: 8.0),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Center(child: Text('2', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),)),
//                             )
//                             // Text(totalOrders.toString()),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: SizedBox(
//                          height: 70,
//                         width: 100,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: const [
//                             Center(
//                               child: Text(
//                                 'Total Wishlist',
//                                 style: TextStyle(fontSize: 13.0),
//                               ),
//                             ),
//                             SizedBox(height: 8.0),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Center(child: Text('3',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),)),
//                             )
//                             // Text(totalWishlist.toString()),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: SizedBox(
//                          height: 70,
//                         width: 100,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: const [
//                             Center(
//                               child: Text(
//                                 'Total Cart',
//                                 style: TextStyle(fontSize: 13.0),
//                               ),
//                             ),
//                             SizedBox(height: 8.0),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Center(child: Text('10', 
//                               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),)),
//                             )
//                             // Text(totalCart.toString()),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                   ),
//                 ),
//               ],
//             ),
//           ),
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Divider(
          //     color: Colors.black12,
          //   ),
          // ),
//           Container(
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(10.0),
//   ),
//   child: ListView.separated(
//     shrinkWrap: true,
//     separatorBuilder: (context, index) {
//       return const Divider(color: Colors.black12);
//     },
//     itemCount: 2,
//     itemBuilder: (BuildContext context, int index) {
//       if (index == 0) {
//         return ListTile(
//           leading: Icon(Icons.shopping_cart),
//           title: const Text(
//             'Orders',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16.0,
//             ),
//           ),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 15,),
//           onTap: () {
//             // Handle tapping on Orders
//           },
//         );
//       } else {
//         return ListTile(
//           leading: Icon(Icons.favorite),
//           title: const Text(
//             'My Wishlist',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16.0,
//             ),
//           ),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 15,),
//           onTap: () {
//             // Handle tapping on Wishlist
//           },
//         );
//       }
//     },
//   ),
// ),
//         ],
        
//       ),
//     );
//   }
// }
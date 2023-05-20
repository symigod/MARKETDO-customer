import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketdo_app/screens/favorite_screen.dart';
import 'login_screen.dart';
import 'orders screen/order_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userId;
  int numOrders = 0; // Add this line to initialize numOrders

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
    fetchOrderCount(); // Call the function to fetch the order count
  }

  Future<void> fetchOrderCount() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: _userId)
          .get();

      setState(() {
        numOrders = snapshot.size;
      });
    } catch (error) {
      print('Error fetching order count: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('customer')
              .doc(_userId)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;

            int numCartItems = 0; // replace with actual number of cart items

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData['logo']),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData['customerName'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(userData['address'], style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text(userData['mobile'], style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text(userData['landMark'], style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orders',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('orders')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (!snapshot.hasData) {
                                    return CircularProgressIndicator();
                                  }

                                  int totalOrders = snapshot.data!.docs.length;

                                  return Text(
                                    totalOrders.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Carts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('product')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (!snapshot.hasData) {
                                    return CircularProgressIndicator();
                                  }

                                  int totalProduct =
                                      snapshot.data!.docs.length;

                                  return Text(
                                    totalProduct.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return const Divider(color: Colors.black12);
                      },
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return ListTile(
                            leading: Icon(Icons.shopping_cart),
                            title: const Text(
                              'Orders',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          OrderScreen()));
                            },
                          );
                        } else {
                          return ListTile(
                            leading: Icon(Icons.favorite),
                            title: const Text(
                              'My Favorites',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          FavoritesScreen()));
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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

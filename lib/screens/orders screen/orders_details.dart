import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_app/widgets/api_widgets.dart';

class OrderDetails extends StatelessWidget {
  final Timestamp time;
  const OrderDetails({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: const Text('Order Details',
                style: TextStyle(color: Colors.white))),
        body: StreamBuilder(
            // stream: getSingleOrder(time),
            builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorWidget(snapshot.error.toString());
          } else {
            if (!snapshot.hasData) {
              return emptyWidget('NO RECORD FOUND!');
            } else {
              return loadingWidget();
              // return ListView.builder(
              //     itemCount: snapshot.data!.length,
              //     itemBuilder: (context, index) {
              //       var address = snapshot.data![index].address;
              //       var customerName = snapshot.data![index].customerName;
              //       var landMark = snapshot.data![index].landMark;
              //       var mobile = snapshot.data![index].mobile;
              //       var orderStatus = snapshot.data![index].orderStatus;
              //       var paymentMethod = snapshot.data![index].paymentMethod;
              //       var products = snapshot.data![index].products.toList();
              //       var shippingFee = snapshot.data![index].shippingFee;
              //       var shippingMethod =
              //           snapshot.data![index].shippingMethod;
              //       var totalAmount = snapshot.data![index].totalAmount;
              //       var totalPrice = snapshot.data![index].totalPrice;
              //       var vendorName = snapshot.data![index].vendorName;

              //       return Card(
              //           elevation: 10,
              //           margin: const EdgeInsets.all(5),
              //           shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               side: const BorderSide(
              //                   color: Colors.black, width: 1)),
              //           child: Padding(
              //               padding: const EdgeInsets.all(10.0),
              //               child: Column(
              //                   crossAxisAlignment:
              //                       CrossAxisAlignment.start,
              //                   children: [
              //                     Text('Order Status: $orderStatus',
              //                         style: const TextStyle(
              //                             fontSize: 14,
              //                             color: Colors.red,
              //                             fontWeight: FontWeight.bold)),
              //                     const SizedBox(height: 10),
              //                     const Text('Customer Information',
              //                         style: TextStyle(
              //                             fontSize: 23,
              //                             fontWeight: FontWeight.bold)),
              //                     const SizedBox(height: 10),
              //                     Text('CUSTOMER NAME: $customerName',
              //                         style: const TextStyle(fontSize: 14)),
              //                     Text('MOBILE NUMBER: $mobile',
              //                         style: const TextStyle(fontSize: 14)),
              //                     Text('ADDRESS: $address',
              //                         style: const TextStyle(fontSize: 14)),
              //                     Text('LANDMARK: $landMark',
              //                         style: const TextStyle(fontSize: 14)),
              //                     const SizedBox(height: 10),
              //                     Text('VENDOR NAME: $vendorName',
              //                         style: const TextStyle(
              //                             fontSize: 22,
              //                             fontWeight: FontWeight.bold)),
              //                     const SizedBox(height: 10),
              //                     ListView.builder(
              //                         shrinkWrap: true,
              //                         itemCount: products.length,
              //                         itemBuilder: (context, index) {
              //                           var productImage = products[index]
              //                                   ['imageUrls']
              //                               .toString()
              //                               .replaceAll('[', '')
              //                               .replaceAll(']', '');
              //                           var productName =
              //                               products[index]['name'];
              //                           var regularPrice =
              //                               products[index]['regularPrice'];

              //                           return ListTile(
              //                               leading: Image.network(
              //                                   productImage.toString()),
              //                               title: Text(
              //                                   'PRODUCT NAME: $productName'),
              //                               subtitle: Text(
              //                                   'PRODUCT NAME: $regularPrice'));
              //                         }),
              //                     const SizedBox(height: 10),
              //                     Text('PAYMENT METHOD: $paymentMethod'),
              //                     Text('SHIPPING METHOD: $shippingMethod'),
              //                     Text('TOTAL PRICE: $totalPrice'),
              //                     Text('SHIPPING FEE: $shippingFee'),
              //                     Text('TOTAL AMOUNT: $totalAmount')
              //                   ])));
              //     });
            }
          }
        })
        // body: SingleChildScrollView(
        //   // physics: const BouncingScrollPhysics(),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         const Divider(color: Colors.grey),
        //         const SizedBox(height: 10),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Expanded(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: const [
        //                   Text('Vendor Name'),
        //                   Text('Missy Godinez',
        //                       style: TextStyle(color: Colors.red)),
        //                   SizedBox(height: 10),
        //                   Text('Order Date'),
        //                   Text('May 11, 2023',
        //                       style: TextStyle(color: Colors.red)),
        //                   SizedBox(height: 10),
        //                   Text('Payment Status'),
        //                   Text('Unpaid', style: TextStyle(color: Colors.red)),
        //                   SizedBox(height: 10),
        //                   Text('Shipping Method'),
        //                   Text('Home Delivery',
        //                       style: TextStyle(color: Colors.grey)),
        //                   SizedBox(height: 10),
        //                   Text('Payment Method'),
        //                   Text('Gcash', style: TextStyle(color: Colors.grey)),
        //                   SizedBox(height: 10),
        //                   Text('Delivery Status'),
        //                   Text('Order Placed',
        //                       style: TextStyle(color: Colors.grey)),
        //                   SizedBox(height: 10),
        //                   Text('Shipping Address'),
        //                   Text('Miss Godinez',
        //                       style: TextStyle(color: Colors.grey)),
        //                   Text(
        //                     'missygodinez123@gmail.com',
        //                     style: TextStyle(color: Colors.grey),
        //                   ),
        //                   Text('09454336652',
        //                       style: TextStyle(color: Colors.grey)),
        //                   Text(
        //                     'Apagan 1, Nasipit, Agusan del Norte',
        //                     style: TextStyle(color: Colors.grey),
        //                   ),
        //                   Text(
        //                     'Near Barangay hall, black gate',
        //                     style: TextStyle(color: Colors.grey),
        //                   ),
        //                   SizedBox(height: 10),
        //                   Text('Total Amount'),
        //                   Text('250.00', style: TextStyle(color: Colors.grey)),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //         const Divider(color: Colors.grey),
        //         const SizedBox(height: 10),
        //         const Center(
        //           child: Text(
        //             'Ordered Product',
        //             style: TextStyle(fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Row(
        //             children: [
        //               Expanded(
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: const [
        //                     Text('Carrots',
        //                         style: TextStyle(fontWeight: FontWeight.bold)),
        //                     Text('1kl'),
        //                     Text('100.00', style: TextStyle(color: Colors.red)),
        //                     SizedBox(height: 10),
        //                     Text('Carrots',
        //                         style: TextStyle(fontWeight: FontWeight.bold)),
        //                     Text('1kl'),
        //                     Text('100.00', style: TextStyle(color: Colors.red)),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         const Divider(color: Colors.grey),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Row(
        //             children: [
        //               Expanded(
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: const [
        //                     Text('SUB TOTAL'),
        //                     Text('250.00'),
        //                     SizedBox(height: 10),
        //                     Text('SHIPPING COST'),
        //                     Text('35.00'),
        //                     SizedBox(height: 10),
        //                     Divider(color: Colors.grey),
        //                     Text('TOTAL'),
        //                     Text('285.00'),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        );
  }
}























// import 'package:flutter/material.dart';

// class OrderDetails extends StatelessWidget {
//   const OrderDetails({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text('Order Details', style: TextStyle(color: Colors.white),),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             Padding(
//           padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children:  const [
//                     Padding(
//                       padding:  EdgeInsets.all(3.0),
//                       child: Icon(Icons.done, color: Colors.red, ),
//                     ),
//                     Padding(
//                       padding:  EdgeInsets.all(3.0),
//                       child: Icon(Icons.thumb_up_outlined, color: Colors.red, ),
//                     ),
//                      Padding(
//                        padding:  EdgeInsets.all(3.0),
//                        child: Icon(Icons.delivery_dining, color: Colors.red, ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.all(3.0),
//                        child: Icon(Icons.done_all_rounded, color: Colors.red, ),
//                      ),
//                   ],
                  
//                 ),
//                 SizedBox(
//                    width: 130,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                  Padding(
//                    padding:  EdgeInsets.all(7.0),
//                    child: Text('Placed'),
//                  ),
//                  Padding(
//                    padding:  EdgeInsets.all(7.0),
//                    child: Text('Vehicle'),
//                  ),
//                  Padding(
//                    padding:  EdgeInsets.all(7.0),
//                    child: Text('On Delivery'),
//                  ),
//                  Padding(
//                    padding:  EdgeInsets.all(7.0),
//                    child: Text('Delivered'),
//                  ),
                 
//               ],
              
//             ),
            
//                 ),
              
//             ],
            
            
//           ),
          
//         ),
//           const Divider(color: Colors.grey,),
//           const SizedBox(height: 10,),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const[
//                         Text('Order Code'),
//                         Text('322524721', style: TextStyle(color: Colors.red),),
//                         SizedBox(height: 10,),
//                         Text('Order Date'),
//                         Text('322524721', style: TextStyle(color: Colors.red),),
//                         SizedBox(height: 10,),
//                         Text('Payment Status'),
//                         Text('Unpaid', style: TextStyle(color: Colors.red),),
//                         SizedBox(height: 10,),
//                         Text('Shipping Method'),
//                         Text('Home Delivery', style: TextStyle(color: Colors.grey),),
//                         SizedBox(height: 10,),
//                         Text('Payment Method'),
//                         Text('Gcash', style: TextStyle(color: Colors.grey),),
//                         SizedBox(height: 10,),
//                         Text('Delivery Status'),
//                         Text('Order Placed', style: TextStyle(color: Colors.grey),),
//                         SizedBox(height: 10,),
//                         Text('Shipping Address'),
//                         Text('Miss Godinez', style: TextStyle(color: Colors.grey),),
//                         Text('missygodinez123@gmail.com', style: TextStyle(color: Colors.grey),),
//                         Text('09454336652', style: TextStyle(color: Colors.grey),),
//                         Text('Apagan 1, Nasipit, Agusan del Norte', style: TextStyle(color: Colors.grey),),
//                         Text('Near Barangay hall, black gate', style: TextStyle(color: Colors.grey),),
//                         SizedBox(height: 10,),
//                         Text('Total Amount'),
//                         Text('250.00', style: TextStyle(color: Colors.grey),),
//                     ],
//                     ),
                    
//                   ],
                  
                  
//                 ),
                
//              ),
//              const Divider(color: Colors.grey,),
//              const Center(
//               child: Text('Ordered Product', style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text('Carrots', style: TextStyle(fontWeight: FontWeight.bold),),
//                       Text('1kl'),
//                       Text('100.00', style: TextStyle(color: Colors.red),),

//                       SizedBox(height: 10,),
//                        Text('Carrots', style: TextStyle(fontWeight: FontWeight.bold),),
//                       Text('1kl'),
//                       Text('100.00', style: TextStyle(color: Colors.red),),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(color: Colors.grey,),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text('SUB TOTAL'),
//                       Text('250.00'),
//                       SizedBox(height: 10,),
//                       Text('SHIPPING COST'),
//                       Text('35.00'),
//                       SizedBox(height: 10,),
//                       Divider(color: Colors.grey,),
//                       Text('TOTAL'),
//                       Text('285.00'),
//                     ],
//                   ),
//                 ],
//               ),
//             )
//           ],    
//         ),
//       )
//     );
//   }
// }
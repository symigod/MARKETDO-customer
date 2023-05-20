// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:flutter/widgets.dart';

// class BrandHighlights extends StatelessWidget {
//   const BrandHighlights ({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Brand Highlights', 
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                   letterSpacing: 1,
//                   fontSize: 20
//                 ),
//                 ),
//             ),
//           ),
//           Container(
//             height: 170,
//             width: MediaQuery.of(context).size.width,
//             color: Colors.white,
//             child: PageView(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 5,
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(8,0,4,8),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(4),
//                               child: Container(
//                                 height: 100, color: Colors.deepOrange,
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 flex: 1,
//                                 child: Container(
//                                   height: 45,
//                                   color: Colors.red,
//                                 ),
//                               )
//                             ],
//                           )
//                         ],
//                       ))
//                   ],
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }








// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:getwidget/components/shimmer/gf_shimmer.dart';
// import 'package:marketdo_app/firebase_services.dart';
// import 'package:marketdo_app/widgets/banner_widget.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class BrandHighLights extends StatefulWidget {
//   const BrandHighLights({Key? key}) : super(key: key);

//   @override
//   State<BrandHighLights> createState() => _BrandHighLightsState();
// }

// class _BrandHighLightsState extends State<BrandHighLights> {

//   double _scrollPosition = 0;
//   final FirebaseService _service = FirebaseService();
//   final List _brandAd = [];

//   @override
//   void initState() {
//     getBrandAd();
//     super.initState();
//   }

//   getBrandAd(){
//     return _service.brandAd
//         .get()
//         .then((QuerySnapshot querySnapshot) {
//       querySnapshot.docs.forEach((doc) {
//         //we get all the documents for banners
//         setState(() {
//           _brandAd.add(doc[doc]);
//         });
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Container(
//       color: Colors.white,
//       child: Column(
//         children: [
//           const SizedBox(height: 18,),
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Brand Highlights',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             height: 166,
//             width: MediaQuery.of(context).size.width,
//             color: Colors.white,
//               child: PageView.builder(
//                 itemCount: _brandAd.length,
//                 itemBuilder: (BuildContext context, int index){
//                   return Row(
//                     children: [
//                       Expanded(
//                         flex: 5,
//                         child: Column(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(8,0,4,8),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(4),
//                                 child: Container(
//                                   height: 100,
//                                   color: Colors.greenAccent,
//                                   child: YoutubePlayer(
//                                     controller: YoutubePlayerController(
//                                       initialVideoId: _brandAd[index]['youtube'],
//                                       flags: const YoutubePlayerFlags(

//                                         autoPlay: false,
//                                         mute: true,
//                                         loop: true,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.fromLTRB(8,0,4,8),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(4),
//                                       child: Container(
//                                         height: 50,
//                                         color: Colors.purple.shade200,
//                                         child: CachedNetworkImage(
//                                           imageUrl: _brandAd[index]['image1'],
//                                           fit: BoxFit.fill,
//                                           placeholder: (context, url)=>GFShimmer(child: Container(
//                                             height: 50,
//                                             color: Colors.grey.shade400,
//                                           ),
//                                           ),

//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.fromLTRB(8,0,4,8),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(4),
//                                       child: Container(
//                                         height: 50,
//                                         color: Colors.purple.shade200,
//                                         child: CachedNetworkImage(
//                                           imageUrl: _brandAd[index]['image2'],
//                                           fit: BoxFit.fill,
//                                           placeholder: (context, url)=>GFShimmer(child: Container(
//                                             height: 50,
//                                             color: Colors.grey.shade400,
//                                           ),
//                                           ),

//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(4,0,8,8),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(4),
//                             child: Container(
//                               height: 160,
//                               color: Colors.greenAccent,
//                               child: CachedNetworkImage(
//                                 imageUrl: _brandAd[index]['image3'],
//                                 fit: BoxFit.fill,
//                                 placeholder: (context, url)=>
//                                     GFShimmer(
//                                         child: Container(
//                                   height: 50,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                     ),

//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   );
//                 },
//                 onPageChanged: (val){
//                   setState(() {
//                     _scrollPosition = val.toDouble();
//                   });
//                 },
//               ),
//           ),
//           _brandAd.isEmpty
//               ? Container()
//               : DotsIndicatorWidget(
//             scrollPosition: _scrollPosition,
//             itemList: _brandAd,
//           ),

//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final favoriteOf;
  late final productIDs;

  FavoriteModel({required this.favoriteOf, required this.productIDs});

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
    return FavoriteModel(
        favoriteOf: data['favoriteOf'], productIDs: data['productIDs']);
  }

  Map<String, dynamic> toFirestore() =>
      {'favoriteOf': favoriteOf, 'productIDs': productIDs};
}

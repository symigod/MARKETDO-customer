import 'package:flutter/material.dart';

Widget errorWidget(String message) =>
    Center(child: Text('AN ERROR OCCURRED!\n$message'));

Widget loadingWidget() => const Center(child: CircularProgressIndicator());

Widget emptyWidget(String message) => Center(child: Text(message));

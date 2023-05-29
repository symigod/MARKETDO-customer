import 'package:flutter/material.dart';

Widget streamErrorWidget(String message) =>
    Center(child: Text('AN ERROR OCCURRED!\n$message'));

Widget streamLoadingWidget() =>
    const Center(child: CircularProgressIndicator());

Widget streamEmptyWidget(String message) => Center(child: Text(message));

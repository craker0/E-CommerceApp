import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: const Duration(days: 1),
    action: SnackBarAction(label: "close", onPressed: (){}),
  ));
}

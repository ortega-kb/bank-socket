import 'package:flutter/material.dart';

class Message {
  static void success({
    required BuildContext context,
    required String message,
  }) {
    _snackBar(context: context, message: message, color: Colors.green);
  }

  static void error({required BuildContext context, required String message}) {
    _snackBar(context: context, message: message, color: Colors.red);
  }

  static void warning({
    required BuildContext context,
    required String message,
  }) {
    _snackBar(context: context, message: message, color: Colors.yellow);
  }

  static void _snackBar({
    required BuildContext context,
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}

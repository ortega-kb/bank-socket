import 'package:flutter/cupertino.dart';

class Validator {
  static String? empty(String? value, BuildContext context) {
    if (value!.isEmpty) {
      return "Ce champ est requis";
    }
    return null;
  }
}

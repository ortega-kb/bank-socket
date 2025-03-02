import 'package:client/core/app.dart';
import 'package:client/core/di.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();

  runApp(App());
}

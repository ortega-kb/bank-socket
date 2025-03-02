import 'package:client/core/theme/app_theme.dart';
import 'package:client/feature/auth/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distributeur Automatique',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: LoginScreen(),
    );
  }
}

import 'dart:io';

import 'package:client/core/shared/widget/primary_button.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/util/message.dart';
import 'package:client/core/security.dart';
import 'package:client/core/util/validator.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const path = 'login';
  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _accountNumberController = TextEditingController();
  final _pinCodeController = TextEditingController();

  @override
  void initState() {
    _initSocket();
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();

    _pinCodeController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
    } else {
      Message.error(context: context, message: "Erreur de connexion");
    }
  }

  void _initSocket() async {
    try {
      final socket = await SecureSocket.connect(
        '127.0.0.1',
        5001,
        context: Security().context(),
      );

      socket.write('WRITE');
    } catch (e) {
      if (!mounted) return;
      Message.error(context: context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppDimen.p16,
                horizontal: width * 0.1,
              ),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimen.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Connexion",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimen.p16),
                      TextFormField(
                        controller: _accountNumberController,
                        decoration: InputDecoration(
                          label: Text("Numero de compte"),
                        ),
                        validator: (value) {
                          return Validator.empty(value, context);
                        },
                      ),
                      const SizedBox(height: AppDimen.p16),
                      TextFormField(
                        controller: _pinCodeController,
                        decoration: InputDecoration(label: Text("Code PIN")),
                        validator: (value) {
                          return Validator.empty(value, context);
                        },
                      ),
                      const SizedBox(height: AppDimen.p32),
                      PrimaryButton(
                        onPressed: () => _login(),
                        text: "Se connecter",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

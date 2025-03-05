import 'package:client/core/shared/widget/primary_button.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/util/message.dart';
import 'package:client/core/util/validator.dart';
import 'package:client/feature/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:client/feature/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const path = '/';
  static const route = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _accountNumberController = TextEditingController();
  final _pinCodeController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginSubmitted(
          accountNumber: _accountNumberController.text.trim(),
          pinCode: _pinCodeController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(AppRoot.route, extra: state.account.toJson());
          } else if (state is AuthError) {
            Message.error(context: context, message: state.message);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.1,
                  vertical: AppDimen.p16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimen.p32),
                    // Carte de connexion
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppDimen.p12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimen.p16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Connexion",
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: AppDimen.p4),
                              Text(
                                "Entrez vos informations de connexion.",
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColor.gray),
                              ),
                              const SizedBox(height: AppDimen.p16),
                              TextFormField(
                                controller: _accountNumberController,
                                decoration: InputDecoration(
                                  labelText: "Numéro de compte",
                                ),
                                validator:
                                    (value) => Validator.empty(value, context),
                              ),
                              const SizedBox(height: AppDimen.p16),
                              TextFormField(
                                controller: _pinCodeController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Code PIN",
                                ),
                                validator:
                                    (value) => Validator.empty(value, context),
                              ),
                              const SizedBox(height: AppDimen.p32),
                              PrimaryButton(
                                onPressed: _login,
                                text: "Se connecter",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

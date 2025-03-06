import 'package:client/core/shared/widget/primary_button.dart';
import 'package:client/core/theme/app_color.dart' show AppColor;
import 'package:client/core/theme/app_dimen.dart';
import 'package:client/core/util/validator.dart';
import 'package:client/feature/auth/presentation/bloc/register/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  static const String path = 'register';
  static const String route = '/register';
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _fixPhoneController = TextEditingController();
  final _portablePhoneController = TextEditingController();
  final _townController = TextEditingController();
  final _pinCodeController = TextEditingController();

  // Liste des types de comptes
  final List<String> _accountTypes = [
    "Compte courant",
    "Livret d'epargne",
    "Plan épargne logement",
    "Plan épargne bancaire",
    "Assurance vie",
  ];

  String? _selectedAccountType;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _fixPhoneController.dispose();
    _portablePhoneController.dispose();
    _townController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    if (_formKey.currentState!.validate()) {
      context.read<RegisterBloc>().add(
        RegisterRequested(
          accountType: _selectedAccountType!,
          address: _addressController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          postalCode: _postalCodeController.text,
          town: _townController.text,
          pinCode: _pinCodeController.text,
          fixPhone: _fixPhoneController.text,
          portablePhone: _portablePhoneController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimen.p16),
                  ),
                  title: const Text('Compte créé avec succès'),
                  content: Text(
                    "Voici vos consignes bancaires :\n\nVotre numéro de compte est : ${state.accountNumber}",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.1,
              vertical: AppDimen.p16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimen.p32),
                // Carte de création de compte
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
                            "Création du compte",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppDimen.p4),
                          Text(
                            "Entrez vos informations de création de compte.",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColor.gray),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: "Prénom",
                            ),
                            validator:
                                (value) => Validator.empty(value, context),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(labelText: "Nom"),
                            validator:
                                (value) => Validator.empty(value, context),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: "Adresse",
                            ),
                            validator:
                                (value) => Validator.empty(value, context),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          TextFormField(
                            controller: _postalCodeController,
                            decoration: const InputDecoration(
                              labelText: "Code postal",
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) => Validator.empty(value, context),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          TextFormField(
                            controller: _townController,
                            decoration: const InputDecoration(
                              labelText: "Ville",
                            ),
                            validator:
                                (value) => Validator.empty(value, context),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          TextFormField(
                            controller: _fixPhoneController,
                            decoration: const InputDecoration(
                              labelText: "Téléphone fixe",
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) => Validator.empty(value, context),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          TextFormField(
                            controller: _portablePhoneController,
                            decoration: const InputDecoration(
                              labelText: "Téléphone portable",
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) => Validator.empty(value, context),
                          ),
                          const SizedBox(height: AppDimen.p16),
                          // Champ pour le type de compte
                          DropdownButtonFormField<String>(
                            value: _selectedAccountType,
                            decoration: const InputDecoration(
                              labelText: "Type de compte",
                            ),
                            items:
                                _accountTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedAccountType = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Veuillez sélectionner un type de compte";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimen.p16),
                          // Champ pour le Code PIN avec une limite de 4 caractères
                          TextFormField(
                            controller: _pinCodeController,
                            decoration: const InputDecoration(
                              labelText: "Code PIN",
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Veuillez entrer un code PIN";
                              }
                              if (value.length != 4) {
                                return "Le code PIN doit contenir 4 chiffres";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimen.p32),
                          PrimaryButton(
                            onPressed: _onCreateAccount,
                            text: "Créer un compte",
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
      ),
    );
  }
}

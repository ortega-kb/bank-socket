import 'package:client/core/app_logger.dart';
import 'package:client/core/data/models/account.dart';
import 'package:client/core/shared/widget/atm_speed_dial.dart';
import 'package:client/core/shared/widget/primary_button.dart';
import 'package:client/core/theme/app_dimen.dart';
import 'package:client/core/util/format_date.dart';
import 'package:client/core/util/message.dart';
import 'package:client/core/util/validator.dart';
import 'package:client/feature/auth/presentation/screen/login_screen.dart';
import 'package:client/feature/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/deposit/deposit_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/download/download_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/transfer/transfer_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/withdraw/withdraw_bloc.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/di.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.account});
  final Account account;

  static const String path = '/dashboard';
  static const String route = '/dashboard';

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    getIt<AppLogger>().logInfo(
      "AppRoot initialisé pour le compte ${widget.account.accountNumber}",
    );
    _initializeDashboard();
  }

  final alertBorderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimen.p16),
  );

  final _withdrawFormKey = GlobalKey<FormState>();
  final _depositFormKey = GlobalKey<FormState>();
  final _transferFormKey = GlobalKey<FormState>();
  final _pinFormKey = GlobalKey<FormState>();

  final _amountWithdrawController = TextEditingController();
  final _amountDepositController = TextEditingController();
  final _amountTransferController = TextEditingController();
  final _accountDstController = TextEditingController();
  final _pinController = TextEditingController();

  void _onWithdraw(double amount, int accountNumber, int pinCode) {
    getIt<AppLogger>().logInfo(
      "Demande de retrait: montant $amount, compte $accountNumber",
    );
    context.read<WithdrawBloc>().add(
      WithdrawRequested(
        accountNumber: accountNumber,
        pinCode: pinCode,
        amount: amount,
      ),
    );
  }

  void _onDeposit(double amount, int accountNumber, int pinCode) {
    getIt<AppLogger>().logInfo(
      "Demande de dépôt: montant $amount, compte $accountNumber",
    );
    context.read<DepositBloc>().add(
      DepositRequested(
        accountNumber: accountNumber,
        amount: amount,
        pinCode: pinCode,
      ),
    );
  }

  void _onTransfer(
    double amount,
    int srcAccount,
    int destAccount,
    int pinCode,
  ) {
    getIt<AppLogger>().logInfo(
      "Demande de transfert: montant $amount, de ${widget.account.accountNumber} vers $destAccount",
    );
    context.read<TransferBloc>().add(
      TransferRequested(
        amount: amount,
        srcAccount: widget.account.accountNumber,
        destAccount: destAccount,
        pinCode: pinCode,
      ),
    );
  }

  void _onDownloadHistory() async {
    getIt<AppLogger>().logInfo(
      "Demande de téléchargement de l'historique pour le compte ${widget.account.accountNumber}",
    );
    context.read<DownloadBloc>().add(
      DownloadRequested(widget.account.accountNumber),
    );
  }

  // Fonction générique pour afficher une boîte de dialogue avec formulaire
  void _showAlertDialog({
    required BuildContext context,
    required String title,
    required String contentText,
    required String buttonText,
    required VoidCallback onPressed,
    required GlobalKey<FormState> formKey,
    List<Widget> additionalFields = const [],
  }) {
    getIt<AppLogger>().logInfo("Affichage de la boîte de dialogue: $title");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: alertBorderShape,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(title),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(contentText),
                  const SizedBox(height: AppDimen.p16),
                  ...additionalFields,
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                getIt<AppLogger>().logInfo(
                  "Annulation de la boîte de dialogue: $title",
                );
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            PrimaryButton(text: buttonText, onPressed: onPressed),
          ],
        );
      },
    );
  }

  // Boîte de dialogue de confirmation pour récapituler l'opération
  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    getIt<AppLogger>().logInfo("Affichage du dialogue de confirmation: $title");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: alertBorderShape,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                getIt<AppLogger>().logInfo(
                  "Annulation du dialogue de confirmation: $title",
                );
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            PrimaryButton(
              text: "Confirmer",
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  // Dialogue de saisie du code PIN
  void _showPinDialog(BuildContext context, VoidCallback onConfirm) {
    _showAlertDialog(
      context: context,
      title: "Vérification PIN",
      contentText: "Entrez votre code PIN pour valider l’opération.",
      buttonText: "Confirmer",
      formKey: _pinFormKey,
      onPressed: () {
        if (_pinFormKey.currentState!.validate()) {
          getIt<AppLogger>().logInfo(
            "Code PIN validé, confirmation de l'opération",
          );
          Navigator.pop(context);
          onConfirm();
        }
      },
      additionalFields: [
        TextFormField(
          controller: _pinController,
          decoration: InputDecoration(labelText: "Code PIN"),
          obscureText: true,
          validator: (value) => Validator.empty(value, context),
        ),
      ],
    );
  }

  // Retrait avec confirmation récapitulative
  void _showWithdrawAlertDialog(BuildContext context) {
    _showAlertDialog(
      context: context,
      title: "Retrait",
      contentText: "Entrez le montant à retirer (USD).",
      buttonText: "Continuer",
      formKey: _withdrawFormKey,
      onPressed: () {
        if (_withdrawFormKey.currentState!.validate()) {
          Navigator.pop(context);
          _showConfirmationDialog(
            context: context,
            title: "Confirmation de Retrait",
            content:
                "Voulez-vous vraiment retirer ${_amountWithdrawController.text} USD ?",
            onConfirm: () {
              _showPinDialog(context, () {
                _onWithdraw(
                  double.parse(_amountWithdrawController.text),
                  widget.account.accountNumber,
                  int.parse(_pinController.text),
                );
              });
            },
          );
        }
      },
      additionalFields: [
        TextFormField(
          controller: _amountWithdrawController,
          decoration: InputDecoration(labelText: "Montant (USD)"),
          validator: (value) => Validator.empty(value, context),
        ),
      ],
    );
  }

  // Dépôt avec confirmation récapitulative
  void _showDepositAlertDialog(BuildContext context) {
    _showAlertDialog(
      context: context,
      title: "Dépôt",
      contentText: "Entrez le montant à déposer.",
      buttonText: "Continuer",
      formKey: _depositFormKey,
      onPressed: () {
        if (_depositFormKey.currentState!.validate()) {
          Navigator.pop(context);
          _showConfirmationDialog(
            context: context,
            title: "Confirmation de Dépôt",
            content:
                "Voulez-vous vraiment déposer ${_amountDepositController.text} USD ?",
            onConfirm: () {
              _showPinDialog(context, () {
                _onDeposit(
                  double.parse(_amountDepositController.text),
                  widget.account.accountNumber,
                  int.parse(_pinController.text),
                );
              });
            },
          );
        }
      },
      additionalFields: [
        TextFormField(
          controller: _amountDepositController,
          decoration: InputDecoration(labelText: "Montant (USD)"),
          validator: (value) => Validator.empty(value, context),
        ),
      ],
    );
  }

  // Transfert avec confirmation récapitulative
  void _showTransferAlertDialog(BuildContext context) {
    _showAlertDialog(
      context: context,
      title: "Transfert",
      contentText: "Entrez les informations nécessaires au transfert.",
      buttonText: "Continuer",
      formKey: _transferFormKey,
      onPressed: () {
        if (_transferFormKey.currentState!.validate()) {
          Navigator.pop(context);
          _showConfirmationDialog(
            context: context,
            title: "Confirmation de Transfert",
            content:
                "Voulez-vous vraiment transférer ${_amountTransferController.text} USD vers le compte ${_accountDstController.text} ?",
            onConfirm: () {
              _showPinDialog(context, () {
                _onTransfer(
                  double.parse(_amountTransferController.text),
                  widget.account.accountNumber,
                  int.parse(_accountDstController.text),
                  int.parse(_pinController.text),
                );
              });
            },
          );
        }
      },
      additionalFields: [
        TextFormField(
          controller: _accountDstController,
          decoration: InputDecoration(labelText: "Compte du destinataire"),
          validator: (value) => Validator.empty(value, context),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppDimen.p16),
        TextFormField(
          controller: _amountTransferController,
          decoration: InputDecoration(labelText: "Montant (USD)"),
          validator: (value) => Validator.empty(value, context),
        ),
      ],
    );
  }

  void _initializeDashboard() {
    getIt<AppLogger>().logInfo(
      "Chargement du dashboard pour le compte ${widget.account.accountNumber}",
    );
    context.read<DashboardBloc>().add(
      DashboardLoadRequested(widget.account.accountNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WithdrawBloc, WithdrawState>(
          listener: (context, state) {
            if (state is WithdrawSuccess) {
              getIt<AppLogger>().logInfo(
                "Retrait réussi pour le compte ${widget.account.accountNumber}",
              );
              Message.success(
                context: context,
                message: "Retrait effectué avec succès",
              );
              _amountWithdrawController.clear();
              _pinController.clear();
              _initializeDashboard();
            } else if (state is WithdrawError) {
              getIt<AppLogger>().logError(
                "Erreur lors du retrait: ${state.message}",
              );
              _amountWithdrawController.clear();
              _pinController.clear();
              Message.error(context: context, message: state.message);
            }
          },
        ),
        BlocListener<DepositBloc, DepositState>(
          listener: (context, state) {
            if (state is DepositSuccess) {
              getIt<AppLogger>().logInfo(
                "Dépôt réussi pour le compte ${widget.account.accountNumber}",
              );
              Message.success(
                context: context,
                message: "Dépôt effectué avec succès",
              );
              _amountDepositController.clear();
              _pinController.clear();
              _initializeDashboard();
            } else if (state is DepositError) {
              getIt<AppLogger>().logError(
                "Erreur lors du dépôt: ${state.message}",
              );
              _amountDepositController.clear();
              _pinController.clear();
              Message.error(context: context, message: state.message);
            }
          },
        ),
        BlocListener<TransferBloc, TransferState>(
          listener: (context, state) {
            if (state is TransferSuccess) {
              getIt<AppLogger>().logInfo(
                "Transfert réussi pour le compte ${widget.account.accountNumber}",
              );
              Message.success(
                context: context,
                message: "Transfert effectué avec succès",
              );
              _amountTransferController.clear();
              _accountDstController.clear();
              _pinController.clear();
              _initializeDashboard();
            } else if (state is TransferError) {
              getIt<AppLogger>().logError(
                "Erreur lors du transfert: ${state.message}",
              );
              _amountTransferController.clear();
              _pinController.clear();
              Message.error(context: context, message: state.message);
            }
          },
        ),
        BlocListener<DownloadBloc, DownloadState>(
          listener: (context, state) {
            if (state is DownloadSuccess) {
              getIt<AppLogger>().logInfo(
                "Téléchargement de l'historique réussi pour le compte ${widget.account.accountNumber}",
              );
              Message.success(
                context: context,
                message: "Téléchargement effectué avec succès",
              );
            } else if (state is DownloadError) {
              getIt<AppLogger>().logError(
                "Erreur lors du téléchargement: ${state.message}",
              );
              Message.error(context: context, message: state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(FluentIcons.person_12_filled),
          title: Text(
            'Salut, ${widget.account.surname} - N° compte: ${widget.account.accountNumber}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            IconButton(
              onPressed: () => _initializeDashboard(),
              icon: Icon(Icons.refresh),
            ),
            const SizedBox(width: AppDimen.p2),
            TextButton(
              child: Text(
                "Se déconnecter",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                getIt<AppLogger>().logInfo(
                  "Déconnexion demandée pour le compte ${widget.account.accountNumber}",
                );
                context.go(LoginScreen.route);
              },
            ),
            const SizedBox(width: AppDimen.p16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomScrollView(
            slivers: [
              BuildHeaderSection(),
              BuildBodySection(
                onDownloadHistory: () {
                  _onDownloadHistory();
                },
              ),
            ],
          ),
        ),
        floatingActionButton: AtmSpeedDial(
          onDeposit: () => _showDepositAlertDialog(context),
          onTransfer: () => _showTransferAlertDialog(context),
          onWithdraw: () => _showWithdrawAlertDialog(context),
        ),
      ),
    );
  }
}

class BuildHeaderSection extends StatelessWidget {
  const BuildHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppDimen.p8,
          right: AppDimen.p16,
          left: AppDimen.p16,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimen.p16),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return ListTile(
                title: Text("Balance"),
                subtitle: Text(
                  (state is DashboardLoaded)
                      ? state.amount.toStringAsFixed(2)
                      : "0.00",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text("USD"),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BuildBodySection extends StatelessWidget {
  const BuildBodySection({super.key, required this.onDownloadHistory});
  final Function()? onDownloadHistory;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimen.p16,
          vertical: AppDimen.p16,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimen.p16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimen.p12),
          ),
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Historique",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed:
                            (state is DashboardLoaded)
                                ? state.histories.isEmpty
                                    ? null
                                    : onDownloadHistory
                                : null,
                        icon: Icon(FluentIcons.arrow_download_24_filled),
                        label: Text("Télécharger"),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimen.p16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimen.p16),
                            ),
                            columnSpacing: 20,
                            horizontalMargin: 10,
                            columns: const [
                              DataColumn(
                                label: Center(
                                  child: Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Center(
                                  child: Text(
                                    "Libelle",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Center(
                                  child: Text(
                                    "Montant USD",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows:
                                (state is DashboardLoaded)
                                    ? state.histories
                                        .map(
                                          (history) => DataRow(
                                            cells: [
                                              DataCell(
                                                Text(formatDate(history.date)),
                                              ),
                                              DataCell(Text(history.libelle)),
                                              DataCell(
                                                Text(
                                                  history.amount
                                                      .toStringAsFixed(2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList()
                                    : List.generate(
                                      1,
                                      (index) => DataRow(
                                        cells: [
                                          DataCell(Text("No data yet")),
                                          DataCell(Text("No data yet")),
                                          DataCell(Text("No data yet")),
                                        ],
                                      ),
                                    ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

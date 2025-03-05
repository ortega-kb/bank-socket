import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class AtmSpeedDial extends StatelessWidget {
  const AtmSpeedDial({
    super.key,
    required this.onTransfer,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final Function()? onTransfer;
  final Function()? onDeposit;
  final Function()? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      overlayOpacity: 0.5,
      label: Text("Nouvelle operation"),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.swap_horiz),
          label: 'Transfert',
          labelStyle: const TextStyle(fontSize: 16),
          onTap: onTransfer,
        ),
        SpeedDialChild(
          child: const Icon(Icons.account_balance_wallet),
          label: 'Dépôt',
          labelStyle: const TextStyle(fontSize: 16),
          onTap: onDeposit,
        ),
        SpeedDialChild(
          child: const Icon(Icons.money_off),
          label: 'Retrait',
          labelStyle: const TextStyle(fontSize: 16),
          onTap: onWithdraw,
        ),
      ],
    );
  }
}

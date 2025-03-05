part of 'transfer_bloc.dart';

sealed class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object> get props => [];
}

final class TransferRequested extends TransferEvent {
  final int srcAccount;
  final int destAccount;
  final double amount;
  final int pinCode;

  const TransferRequested({
    required this.srcAccount,
    required this.destAccount,
    required this.amount,
    required this.pinCode,
  });

  @override
  List<Object> get props => [srcAccount, destAccount, amount, pinCode];
}

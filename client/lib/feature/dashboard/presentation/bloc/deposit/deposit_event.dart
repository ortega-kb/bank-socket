part of 'deposit_bloc.dart';

sealed class DepositEvent extends Equatable {
  const DepositEvent();

  @override
  List<Object> get props => [];
}

final class DepositRequested extends DepositEvent {
  final int accountNumber;
  final int pinCode;
  final double amount;

  const DepositRequested({
    required this.accountNumber,
    required this.pinCode,
    required this.amount,
  });

  @override
  List<Object> get props => [accountNumber, pinCode, amount];
}

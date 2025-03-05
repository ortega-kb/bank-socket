part of 'withdraw_bloc.dart';

sealed class WithdrawEvent extends Equatable {
  const WithdrawEvent();

  @override
  List<Object> get props => [];
}

final class WithdrawRequested extends WithdrawEvent {
  final int accountNumber;
  final double amount;
  final int pinCode;

  const WithdrawRequested({
    required this.accountNumber,
    required this.amount,
    required this.pinCode,
  });

  @override
  List<Object> get props => [accountNumber, amount, pinCode];
}

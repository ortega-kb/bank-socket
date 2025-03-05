part of 'withdraw_bloc.dart';

sealed class WithdrawState extends Equatable {
  const WithdrawState();

  @override
  List<Object> get props => [];
}

final class WithdrawInitial extends WithdrawState {}

final class WithdrawLoading extends WithdrawState {}

final class WithdrawSuccess extends WithdrawState {}

final class WithdrawError extends WithdrawState {
  final String message;
  const WithdrawError(this.message);

  @override
  List<Object> get props => [message];
}

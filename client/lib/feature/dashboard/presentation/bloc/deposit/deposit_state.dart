part of 'deposit_bloc.dart';

sealed class DepositState extends Equatable {
  const DepositState();

  @override
  List<Object> get props => [];
}

final class DepositInitial extends DepositState {}

final class DepositLoading extends DepositState {}

final class DepositSuccess extends DepositState {}

final class DepositError extends DepositState {
  final String message;
  const DepositError(this.message);

  @override
  List<Object> get props => [message];
}

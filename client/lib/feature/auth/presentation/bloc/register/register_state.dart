part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  final String accountNumber;
  const RegisterSuccess(this.accountNumber);

  @override
  List<Object> get props => [accountNumber];
}

final class RegisterError extends RegisterState {
  final String message;
  const RegisterError(this.message);

  @override
  List<Object> get props => [message];
}

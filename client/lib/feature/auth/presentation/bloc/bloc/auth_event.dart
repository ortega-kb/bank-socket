part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthLoginSubmitted extends AuthEvent {
  final String accountNumber;
  final String pinCode;

  const AuthLoginSubmitted({
    required this.accountNumber,
    required this.pinCode,
  });

  @override
  List<Object> get props => [accountNumber, pinCode];
}

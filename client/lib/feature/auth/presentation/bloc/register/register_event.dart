part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

final class RegisterRequested extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String address;
  final String postalCode;
  final String fixPhone;
  final String portablePhone;
  final String town;
  final String accountType;
  final String pinCode;

  const RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.postalCode,
    required this.fixPhone,
    required this.portablePhone,
    required this.town,
    required this.accountType,
    required this.pinCode
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    address,
    postalCode,
    fixPhone,
    portablePhone,
    town,
    accountType,
    pinCode
  ];
}

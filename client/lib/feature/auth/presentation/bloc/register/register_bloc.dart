import 'dart:convert';

import 'package:client/core/data/client_repository.dart';
import 'package:client/core/util/app_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final ClientRepository _clientRepository;
  RegisterBloc(this._clientRepository) : super(RegisterInitial()) {
    on<RegisterRequested>(_onRegister);
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    final user = {
      "first_name": event.firstName,
      "last_name": event.lastName,
      "address": event.address,
      "postal_code": event.postalCode,
      "fix_phone": event.fixPhone,
      "portable_phone": event.portablePhone,
      "town": event.town,
      "account_type": event.accountType,
      "pin_code": event.pinCode,
    };

    final registerRequest = 'REGISTER ${json.encode(user)}';
    final registerResponse = await _clientRepository.register(registerRequest);

    if (registerResponse.status == AppResponse.registerOk) {
      emit(RegisterSuccess(registerResponse.data.toString()));
    } else {
      emit(RegisterError('Erreur d\'enregistrement ${registerResponse.data}'));
    }
  }
}

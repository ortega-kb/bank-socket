import 'package:client/core/data/client_repository.dart';
import 'package:client/core/data/models/account.dart';
import 'package:client/core/util/app_response.dart';
import 'package:client/core/util/socket_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ClientRepository _clientRepository;

  AuthBloc(this._clientRepository) : super(AuthInitial()) {
    on<AuthLoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final request = 'TESTPIN ${event.accountNumber} ${event.pinCode}';
    final SocketResponse response = await _clientRepository.testPin(request);

    if (response.status == AppResponse.testPinOk) {
      final account = Account.fromJson(response.data);
      emit(AuthSuccess(account));
    } else {
      emit(AuthError("Erreur d'authentification - PIN incorrect"));
    }
  }
}

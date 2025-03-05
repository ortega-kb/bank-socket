import 'package:client/core/data/client_repository.dart';
import 'package:client/core/util/app_response.dart';
import 'package:client/core/util/socket_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'deposit_event.dart';
part 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final ClientRepository _clientRepository;

  DepositBloc(this._clientRepository) : super(DepositInitial()) {
    on<DepositRequested>(_onDeposit);
  }

  Future<void> _onDeposit(
    DepositRequested event,
    Emitter<DepositState> emit,
  ) async {
    emit(DepositLoading());
    final depositRequest = 'DEPOSIT ${event.accountNumber} ${event.amount}';

    final pinRequest = 'TESTPIN ${event.accountNumber} ${event.pinCode}';
    final SocketResponse pinResponse = await _clientRepository.testPin(
      pinRequest,
    );

    if (pinResponse.status == AppResponse.testPinOk) {
      final depositResponse = await _clientRepository.deposit(depositRequest);

      if (depositResponse.status == AppResponse.depositOk) {
        emit(DepositSuccess());
      } else {
        emit(DepositError("Erreur de retrait - ${depositResponse.data}"));
      }
    } else {
      emit(DepositError("Pin code incorrect"));
    }
  }
}

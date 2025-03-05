import 'package:client/core/data/client_repository.dart';
import 'package:client/core/util/app_response.dart';
import 'package:client/core/util/socket_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transfer_event.dart';
part 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final ClientRepository _clientRepository;
  TransferBloc(this._clientRepository) : super(TransferInitial()) {
    on<TransferRequested>(_onTransfer);
  }

  Future<void> _onTransfer(
    TransferRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(TrasnferLoading());
    final transferRequest =
        'TRANSFER ${event.srcAccount} ${event.destAccount} ${event.amount}';

    final pinRequest = 'TESTPIN ${event.srcAccount} ${event.pinCode}';
    final SocketResponse pinResponse = await _clientRepository.testPin(
      pinRequest,
    );

    if (pinResponse.status == AppResponse.testPinOk) {
      final transferResponse = await _clientRepository.withdraw(
        transferRequest,
      );
      if (transferResponse.status == AppResponse.tranferOk) {
        emit(TransferSuccess());
      } else {
        emit(TransferError("Erreur de transfer - ${transferResponse.data}"));
      }
    } else {
      emit(TransferError("Pin code incorrect"));
    }
  }
}

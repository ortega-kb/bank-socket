import 'package:client/core/data/client_repository.dart';
import 'package:client/core/util/app_response.dart';
import 'package:client/core/util/socket_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'withdraw_event.dart';
part 'withdraw_state.dart';

class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final ClientRepository _clientRepository;
  WithdrawBloc(this._clientRepository) : super(WithdrawInitial()) {
    on<WithdrawRequested>(_onWithdraw);
  }

  Future<void> _onWithdraw(
    WithdrawRequested event,
    Emitter<WithdrawState> emit,
  ) async {
    emit(WithdrawLoading());
    final withdrawRequest = 'WITHDRAW ${event.accountNumber} ${event.amount}';

    final pinRequest = 'TESTPIN ${event.accountNumber} ${event.pinCode}';
    final SocketResponse pinResponse = await _clientRepository.testPin(
      pinRequest,
    );

    if (pinResponse.status == AppResponse.testPinOk) {
      final withdrawResponse = await _clientRepository.withdraw(
        withdrawRequest,
      );

      if (withdrawResponse.status == AppResponse.withdrawOk) {
        emit(WithdrawSuccess());
      } else {
        emit(WithdrawError("Erreur de retrait - ${withdrawResponse.data}"));
      }
    } else {
      emit(WithdrawError("Pin code incorrect"));
    }
  }
}

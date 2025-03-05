import 'package:client/core/data/client_repository.dart';
import 'package:client/core/data/models/history.dart';
import 'package:client/core/util/app_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ClientRepository _clientRepository;

  DashboardBloc(this._clientRepository) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoaded);
  }

  Future<void> _onDashboardLoaded(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final balanceResponse = await _clientRepository.balance(
        'BALANCE ${event.accountNumber}',
      );

      if (balanceResponse.status != AppResponse.balanceOk) {
        emit(DashboardError('Failed to fetch balance.'));
        return;
      }

      final historyResponse = await _clientRepository.history(
        'HISTORY ${event.accountNumber}',
      );

      if (historyResponse.status != AppResponse.history) {
        emit(DashboardError('Failed to fetch history.'));
        return;
      }

      final double balance = (balanceResponse.data as double);
      final List<History> histories =
          (historyResponse.data is List)
              ? (historyResponse.data as List)
                  .cast<Map<String, dynamic>>()
                  .map(History.fromJson)
                  .toList()
              : [];

      emit(DashboardLoaded(amount: balance, histories: histories));
    } catch (e) {
      emit(DashboardError('An error occurred: $e'));
    }
  }
}

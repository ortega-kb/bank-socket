part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

final class DashboardLoadRequested extends DashboardEvent {
  final int accountNumber;
  const DashboardLoadRequested(this.accountNumber);

  @override
  List<Object> get props => [accountNumber];
}

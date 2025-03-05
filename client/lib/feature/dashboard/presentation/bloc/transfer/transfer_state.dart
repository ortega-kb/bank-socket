part of 'transfer_bloc.dart';

sealed class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object> get props => [];
}

final class TransferInitial extends TransferState {}

final class TrasnferLoading extends TransferState {}

final class TransferSuccess extends TransferState {}

final class TransferError extends TransferState {
  final String message;
  const TransferError(this.message);

  @override
  List<Object> get props => [message];
}

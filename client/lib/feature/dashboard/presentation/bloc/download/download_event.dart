part of 'download_bloc.dart';

sealed class DownloadEvent extends Equatable {
  const DownloadEvent();

  @override
  List<Object> get props => [];
}

final class DownloadRequested extends DownloadEvent {
  final int accountNumber;
  const DownloadRequested(this.accountNumber);

  @override
  List<Object> get props => [accountNumber];
}

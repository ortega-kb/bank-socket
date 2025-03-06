part of 'download_bloc.dart';

sealed class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object> get props => [];
}

final class DownloadInitial extends DownloadState {}

final class DownloadLoading extends DownloadState {}

final class DownloadSuccess extends DownloadState {}

final class DownloadError extends DownloadState {
  final String message;
  const DownloadError(this.message);

  @override
  List<Object> get props => [message];
}

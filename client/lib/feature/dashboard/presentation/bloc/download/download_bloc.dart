import 'dart:io';

import 'package:client/core/data/client_repository.dart';
import 'package:client/core/util/app_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final ClientRepository _clientRepository;
  DownloadBloc(this._clientRepository) : super(DownloadInitial()) {
    on<DownloadRequested>(_onDownload);
  }

  Future<void> _onDownload(
    DownloadRequested event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadLoading());

    final historyCSVRequest = 'HISTORY_CSV ${event.accountNumber}';
    final historyCSVResponse = await _clientRepository.historyCSV(
      historyCSVRequest,
    );

    if (historyCSVResponse.status == AppResponse.history) {
      final downloadResponse = await _clientRepository.downloadFile(
        historyCSVResponse.data,
      );

      if (downloadResponse.status == AppResponse.downloadOk) {
        final Map<String, dynamic> data = downloadResponse.data;
        final String fileName = data["file_name"];
        final List<int> fileBytes = data["file_bytes"];

        // Sauvegarde du fichier localement dans le répertoire des documents
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String localFilePath = '${appDocDir.path}/$fileName';
        File localFile = File(localFilePath);
        await localFile.writeAsBytes(fileBytes);

        emit(DownloadSuccess());
      }
    } else {
      emit(
        DownloadError('Erreur de telechargement - ${historyCSVResponse.data}'),
      );
    }
  }
}

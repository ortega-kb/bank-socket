import 'dart:convert';
import 'dart:io';

import 'package:client/core/data/client_repository.dart';
import 'package:client/core/util/app_response.dart';
import 'package:client/core/util/socket_response.dart';

class ClientRepositoryImpl extends ClientRepository {
  final SecureSocket _socket;
  late final Stream<List<int>> _socketStream;

  ClientRepositoryImpl(this._socket) {
    _socketStream = _socket.asBroadcastStream();
  }

  Future<SocketResponse> _sendRequest(String request) async {
    try {
      _socket.write(request);
      await _socket.flush();

      final response = await _socketStream.first;
      final decodedResponse = utf8.decode(response);
      return SocketResponse.fromJson(json.decode(decodedResponse));
    } catch (e) {
      return SocketResponse(
        data: e.toString(),
        status: AppResponse.errOperation,
      );
    }
  }

  /// Fonction pour télécharger un fichier depuis le serveur via socket.
  /// La commande "DOWNLOAD <file_path>" est envoyée, puis la réponse JSON
  /// contient le nom du fichier et son contenu encodé en base64.
  /// Cette fonction décode le contenu et renvoie le résultat dans SocketResponse.
  @override
  Future<SocketResponse> downloadFile(String filePath) async {
    try {
      String downloadRequest = "DOWNLOAD $filePath\n";
      _socket.write(downloadRequest);
      await _socket.flush();

      final response = await _socketStream.first;
      final decodedResponse = utf8.decode(response);
      final Map<String, dynamic> jsonResponse = json.decode(decodedResponse);
      SocketResponse socketResponse = SocketResponse.fromJson(jsonResponse);

      // Vérifier si le téléchargement est réussi et si le contenu existe.
      if (socketResponse.status == AppResponse.downloadOk &&
          socketResponse.data != null &&
          socketResponse.data is Map &&
          (socketResponse.data as Map).containsKey("file_content")) {
        final Map<String, dynamic> data = socketResponse.data;
        String base64Content = data["file_content"];
        List<int> fileBytes = base64Decode(base64Content);
        return SocketResponse(
          status: socketResponse.status,
          data: {"file_name": data["file_name"], "file_bytes": fileBytes},
        );
      }
      return socketResponse;
    } catch (e) {
      return SocketResponse(
        data: e.toString(),
        status: AppResponse.errOperation,
      );
    }
  }

  @override
  Future<SocketResponse> balance(String request) async {
    return await _sendRequest(request);
  }

  @override
  Future<SocketResponse> deposit(String request) async {
    return await _sendRequest(request);
  }

  @override
  Future<SocketResponse> history(String request) async {
    return await _sendRequest(request);
  }

  @override
  Future<SocketResponse> testPin(String request) async {
    return await _sendRequest(request);
  }

  @override
  Future<SocketResponse> transfer(String request) async {
    return await _sendRequest(request);
  }

  @override
  Future<SocketResponse> withdraw(String request) async {
    return await _sendRequest(request);
  }

  @override
  Future<SocketResponse> historyCSV(String request) async {
    return await _sendRequest(request);
  }
}

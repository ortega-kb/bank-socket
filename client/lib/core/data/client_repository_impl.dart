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
}

import 'package:client/core/util/socket_response.dart';

abstract class ClientRepository {
  Future<SocketResponse> testPin(String request);
  Future<SocketResponse> balance(String request);
  Future<SocketResponse> withdraw(String request);
  Future<SocketResponse> deposit(String request);
  Future<SocketResponse> history(String request);
  Future<SocketResponse> transfer(String request);
  Future<SocketResponse> historyCSV(String request);
  Future<SocketResponse> register(String request);
  Future<SocketResponse> downloadFile(String filePath);
}

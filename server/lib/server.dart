import 'dart:io';
import 'package:server/core/app_logger.dart';
import 'package:server/core/config/app_config.dart';
import 'package:server/core/data/app_operation.dart';
import 'package:server/core/di.dart';
import 'package:server/core/security.dart';

class Server {
  final AppOperation _appOperation;
  const Server(this._appOperation);

  Future<void> run() async {
    final config = getIt<AppConfig>();
    final security = getIt<Security>();

    final server = await SecureServerSocket.bind(
      config.serverHost,
      int.parse(config.serverPort),
      security.context(),
    );

    getIt<AppLogger>().logInfo(
      "Secure bank server started on ${config.serverHost}:${config.serverPort}...",
    );

    await for (var client in server) {
      _handleClient(client);
    }
  }

  void _handleClient(SecureSocket client) {
    getIt<AppLogger>().logInfo(
      "New connection from ${client.remoteAddress.address}:${client.port}",
    );

    client.listen(
      (data) async {
        final request = String.fromCharCodes(data).trim();
        final response = _appOperation.processOperation(request);
        client.writeln(response);
      },
      onDone: () => _closeClient(client),
      onError: (error) => _handleClientError(client, error),
    );
  }

  void _closeClient(SecureSocket client) {
    getIt<AppLogger>().logInfo(
      "Connection closed for ${client.remoteAddress.address}:${client.port}",
    );
    client.destroy();
  }

  void _handleClientError(SecureSocket client, dynamic error) {
    getIt<AppLogger>().logError(
      "Error client ${client.remoteAddress.address}:${client.port} - $error",
    );
    client.destroy();
  }
}

import 'dart:io';

import 'package:server/core/app_logger.dart';
import 'package:server/core/app_config.dart';
import 'package:server/core/di.dart';
import 'package:server/core/security.dart';

class Server {
  void run() async {
    final serverHost = getIt<AppConfig>().serverHost;
    final serverPort = int.parse(getIt<AppConfig>().serverPort);
    final securityContext = getIt<Security>().context();

    final server = await SecureServerSocket.bind(
      serverHost,
      serverPort,
      securityContext,
    );

    getIt<AppLogger>().logInfo(
      "Secure bank server started on host $serverHost on port $serverPort ...",
    );

    try {
      // Create async loop to handle multiple clients
      await for (SecureSocket client in server) {
        handleClient(client);
      }
    } on SocketException catch (e) {
      getIt<AppLogger>().logError(e.message);
    }
  }

  void handleClient(SecureSocket client) async {
    getIt<AppLogger>().logInfo(
      "New connection from ${client.address.host}:${client.port}",
    );

    client.listen(
      (data) {},
      onDone: () {
        getIt<AppLogger>().logInfo(
          "Connection closed for ${client.remoteAddress.address}:${client.port}",
        );
        client.destroy();
      },
      onError: (error) {
        getIt<AppLogger>().logError(
          "Error client ${client.remoteAddress.address}:${client.port} - $error",
        );
        client.destroy();
      },
    );
  }
}

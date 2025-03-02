import 'dart:io';

import 'package:server/core/app_logger.dart';
import 'package:server/core/config.dart';
import 'package:server/core/di.dart';
import 'package:server/core/security.dart';

class Server {
  void run() async {
    final serverHost = getIt<Config>().serverHost;
    final serverPort = int.parse(getIt<Config>().serverPort);
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
      // Pour chaque client, on garde la socket dans l'isolate principal,
      // et on spawn un isolate dédié au traitement des données
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

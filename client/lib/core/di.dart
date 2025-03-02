import 'dart:io';

import 'package:client/core/app_logger.dart';
import 'package:client/core/config.dart';
import 'package:client/core/security.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/web.dart';

final getIt = GetIt.asNewInstance();

Future<void> initializeApp() async {
  final config = Config(DotEnv()..load());
  getIt.registerLazySingleton(() => config);

  getIt.registerLazySingleton(() => AppLogger(Logger()));

  final securityContext = await Security.instance.context();
  getIt.registerSingleton<SecurityContext>(securityContext);

  final serverHost = config.serverHost;
  final serverPort = int.parse(config.serverPort);

  // Secure socket client
  final socketClient = await SecureSocket.connect(
    serverHost,
    serverPort,
    context: securityContext,
  );
  getIt.registerSingleton<SecureSocket>(socketClient);
}

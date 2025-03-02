import 'dart:io';

import 'package:server/core/app_config.dart';
import 'package:server/core/di.dart';

class Security {
  final String serverCert = getIt<AppConfig>().serverCert;
  final String serverKey = getIt<AppConfig>().serverkey;

  static final Security _instance = Security._();
  static Security get instance => _instance;

  Security._();

  SecurityContext context() {
    return SecurityContext()
      ..useCertificateChain(serverCert)
      ..usePrivateKey(serverKey);
  }
}

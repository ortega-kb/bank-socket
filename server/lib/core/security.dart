import 'dart:io';

import 'package:server/core/config.dart';
import 'package:server/core/di.dart';

class Security {
  final String serverCert = getIt<Config>().serverCert;
  final String serverKey = getIt<Config>().serverkey;

  static final Security _instance = Security._();
  static Security get instance => _instance;

  Security._();

  

  SecurityContext context() {
    return SecurityContext()
      ..useCertificateChain(serverCert)
      ..usePrivateKey(serverKey);
  }
}

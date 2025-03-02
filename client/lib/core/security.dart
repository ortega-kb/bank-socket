import 'dart:io';

import 'package:flutter/services.dart';

class Security {
  static String clientCert = 'certificates/client_cert.pem';

  static final Security _instance = Security._();
  static Security get instance => _instance;

  Security._();

  Future<SecurityContext> context() async {
    SecurityContext context = SecurityContext();

    final serverCert = await rootBundle.load(clientCert);
    context.setTrustedCertificatesBytes(serverCert.buffer.asUint8List());
    return context;
  }
}

import 'dart:io';

class Security {
  static String clientCert = 'certificates/client_cert.pem';
  static String clientKey = 'certificates/client_key.pem';

  SecurityContext context() {
    final clientContext = SecurityContext(withTrustedRoots: true);
    clientContext.setTrustedCertificates(clientCert);

    return clientContext;
  }
}

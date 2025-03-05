import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  final DotEnv _dotEnv;
  const Config(this._dotEnv);

  String get serverCert => _dotEnv.env['SERVER_CERT_PATH'] ?? '';
  String get serverkey => _dotEnv.env['SERVER_KEY_PATH'] ?? '';

  String get serverHost => _dotEnv.env['SERVER_HOST'] ?? '';
  String get serverPort => _dotEnv.env['SERVER_PORT'] ?? '';

  String get clientLogPath => _dotEnv.env['CLIENT_LOG_PATH'] ?? '';
}

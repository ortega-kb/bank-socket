import 'package:dotenv/dotenv.dart';

class Config {
  final DotEnv _dotEnv;
  const Config(this._dotEnv);

  String get serverCert => _dotEnv['SERVER_CERT_PATH'] ?? '';
  String get serverkey => _dotEnv['SERVER_KEY_PATH'] ?? '';

  String get dbName => _dotEnv['DB_NAME'] ?? '';
  String get serverHost => _dotEnv['SERVER_HOST'] ?? '';
  String get serverPort => _dotEnv['SERVER_PORT'] ?? '';

  String get serverLogPath => _dotEnv['SERVER_LOG_PATH'] ?? '';
}

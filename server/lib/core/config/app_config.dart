import 'package:dotenv/dotenv.dart';

class AppConfig {
  final DotEnv _dotEnv;
  const AppConfig(this._dotEnv);

  String get serverCert => _dotEnv['SERVER_CERT_PATH'] ?? '';
  String get serverkey => _dotEnv['SERVER_KEY_PATH'] ?? '';

  String get dbName => _dotEnv['DB_NAME'] ?? '';
  String get serverHost => _dotEnv['SERVER_HOST'] ?? '';
  String get serverPort => _dotEnv['SERVER_PORT'] ?? '';

  String get clientsCSV => _dotEnv['CLIENTS_CSV'] ?? '';
  String get comptesCSV => _dotEnv['COMPTES_CSV'] ?? '';
  String get operationsCSV => _dotEnv['OPERATIONS_CSV'] ?? '';

  String get serverLogPath => _dotEnv['SERVER_LOG_PATH'] ?? '';
  String get fileServerPath => _dotEnv['FILE_SERVER_PATH'] ?? '';
}

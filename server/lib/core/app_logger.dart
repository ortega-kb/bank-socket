import 'dart:io';

import 'package:logger/web.dart';
import 'package:server/core/app_config.dart';
import 'package:server/core/di.dart';

enum LogType { info, warning, error }

class AppLogger {
  final String _logFilePath = getIt<AppConfig>().serverLogPath;

  final Logger _logger;
  AppLogger(this._logger);

  void logInfo(String message) {
    _logger.i(message);
    _log(message, LogType.info);
  }

  void logError(String message) {
    _logger.e(message);
    _log(message, LogType.error);
  }

  void logWarning(String message) {
    _logger.w(message);
    _log(message, LogType.warning);
  }

  void _log(String message, LogType logType) {
    final file = File(_logFilePath);
    file.writeAsStringSync(
      '[${DateTime.now()}] - [${logType.name.toUpperCase()}] - $message\n',
      mode: FileMode.append,
    );
  }
}

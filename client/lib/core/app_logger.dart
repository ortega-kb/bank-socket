import 'dart:io';

import 'package:client/core/config/config.dart';
import 'package:client/core/di.dart';
import 'package:logger/web.dart';

enum LogType { info, warning, error }

class AppLogger {
  final String _logFilePath = getIt<Config>().clientLogPath;

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

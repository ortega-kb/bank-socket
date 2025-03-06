import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;

class Config {
  final String serverCert;
  final String serverKey;
  final String serverHost;
  final String serverPort;
  final String clientLogPath;

  Config._({
    required this.serverCert,
    required this.serverKey,
    required this.serverHost,
    required this.serverPort,
    required this.clientLogPath,
  });

  /// Charge la configuration et convertit les chemins relatifs en absolus.
  static Future<Config> load() async {
    final env = dotenv.env;

    final serverCertPath = _getAbsolutePath(env['SERVER_CERT_PATH'] ?? '');
    final serverKeyPath = _getAbsolutePath(env['SERVER_KEY_PATH'] ?? '');
    final clientLogPath = _getAbsolutePath(env['CLIENT_LOG_PATH'] ?? '');

    return Config._(
      serverCert: serverCertPath,
      serverKey: serverKeyPath,
      serverHost: env['SERVER_HOST'] ?? '',
      serverPort: env['SERVER_PORT'] ?? '',
      clientLogPath: clientLogPath,
    );
  }

  /// Convertit un chemin relatif en absolu en fonction du vrai root du projet.
  static String _getAbsolutePath(String path) {
    if (path.isEmpty || p.isAbsolute(path)) return path;

    // Récupère le dossier racine réel du projet
    final projectRoot = _findProjectRoot();

    return p.normalize(p.join(projectRoot, path));
  }

  /// Trouve le dossier root du projet Flutter (là où `pubspec.yaml` est situé)
  static String _findProjectRoot() {
    var current = Directory.current;

    while (current.path.isNotEmpty) {
      if (File(p.join(current.path, 'pubspec.yaml')).existsSync()) {
        return current.path;
      }
      final parent = current.parent;
      if (parent.path == current.path)
        break; 
      current = parent;
    }

    throw Exception("Impossible de trouver le dossier root du projet.");
  }
}

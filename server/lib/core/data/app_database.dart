import 'dart:io';
import 'package:csv/csv.dart';
import 'package:server/core/app_logger.dart';
import 'package:server/core/config/app_config.dart';
import 'package:server/core/di.dart';
import 'package:sqlite3/sqlite3.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;
  static Database get database => _instance._database;

  static final _databaseName = getIt<AppConfig>().dbName;
  late final Database _database;

  AppDatabase._() {
    getIt<AppLogger>().logInfo('Creating the database instance.');
    _database = sqlite3.open(_databaseName);
    initialize();
  }

  void initialize() {
    _createTables();

    _importCsvDataIfNeeded(getIt<AppConfig>().clientsCSV, 'clients');
    _importCsvDataIfNeeded(getIt<AppConfig>().comptesCSV, 'comptes');
    _importCsvDataIfNeeded(getIt<AppConfig>().operationsCSV, 'operations');
  }

  void _createTables() {
    getIt<AppLogger>().logInfo('Creating tables in the database.');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        NumeroClient INTEGER PRIMARY KEY,
        Prenom TEXT,
        Nom TEXT,
        Adresse TEXT,
        CodePostal INTEGER,
        Ville TEXT,
        TelephoneFixe INTEGER,
        TelephonePortable INTEGER
      )
    ''');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS comptes (
        NumeroCompte INTEGER PRIMARY KEY,
        NumeroClient INTEGER,
        TypeCompte TEXT,
        PIN INTEGER,
        Solde REAL,
        FOREIGN KEY (NumeroClient) REFERENCES clients(NumeroClient)
      )
    ''');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS operations (
        NumeroOperation INTEGER PRIMARY KEY,
        DateOperation TEXT,
        NumeroCompte INTEGER,
        LibelleOperation TEXT,
        Montant REAL,
        FOREIGN KEY (NumeroCompte) REFERENCES comptes(NumeroCompte)
      )
    ''');
  }

  bool _tableHasData(String tableName) {
    final result = _database.select('SELECT COUNT(*) AS count FROM $tableName');
    return result.isNotEmpty && result.first['count'] > 0;
  }

  void _importCsvDataIfNeeded(String csvFileName, String tableName) {
    if (_tableHasData(tableName)) {
      getIt<AppLogger>().logInfo(
        'Skipping import for "$tableName", data already exists.',
      );
      return;
    }

    getIt<AppLogger>().logInfo(
      'Importing data from $csvFileName into "$tableName".',
    );

    final file = File(csvFileName);
    if (!file.existsSync()) {
      getIt<AppLogger>().logError('File $csvFileName does not exist.');
      return;
    }

    try {
      final csvContent = file.readAsStringSync();
      final rows = const CsvToListConverter(
        fieldDelimiter: ';',
      ).convert(csvContent);

      if (rows.isEmpty) {
        getIt<AppLogger>().logError('File $csvFileName is empty.');
        return;
      }

      final headers =
          rows.first.map((header) => header.toString().trim()).toList();
      final placeholders = List.filled(headers.length, '?').join(', ');
      final insertQuery =
          'INSERT INTO $tableName (${headers.join(', ')}) VALUES ($placeholders)';

      final stmt = _database.prepare(insertQuery);

      for (int i = 1; i < rows.length; i++) {
        final row =
            rows[i]
                .map((value) => value.toString().replaceAll('"', '').trim())
                .toList();
        try {
          stmt.execute(row);
        } catch (e) {
          getIt<AppLogger>().logError(
            'Error inserting row $i in $tableName: $e',
          );
        }
      }

      stmt.dispose();
      getIt<AppLogger>().logInfo(
        'Data successfully imported into "$tableName".',
      );
    } catch (e) {
      getIt<AppLogger>().logError(
        'Error importing $csvFileName into $tableName: $e',
      );
    }
  }
}

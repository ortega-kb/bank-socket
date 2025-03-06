import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:server/core/app_logger.dart';
import 'package:server/core/config/app_config.dart';
import 'package:server/core/di.dart';
import 'package:server/core/util/app_response.dart';
import 'package:sqlite3/sqlite3.dart';

class AppOperation {
  final Database _database;

  const AppOperation(this._database);

  // Utility method to get the balance of an account
  double _getBalance(int accountNumber) {
    final result = _database.select(
      'SELECT Solde FROM comptes WHERE NumeroCompte = ?',
      [accountNumber],
    );
    getIt<AppLogger>().logInfo(
      'Récupération du solde pour le compte $accountNumber',
    );
    return result.isNotEmpty ? result.first['Solde'] : 0.0;
  }

  // Utility method to record an operation in the 'operations' table
  void _recordOperation(int accountNumber, String libelle, double montant) {
    _database.execute(
      'INSERT INTO operations (NumeroCompte, DateOperation, LibelleOperation, Montant) VALUES (?, ?, ?, ?)',
      [accountNumber, DateTime.now().toIso8601String(), libelle, montant],
    );
    getIt<AppLogger>().logInfo(
      'Opération enregistrée: $libelle de $montant sur le compte $accountNumber',
    );
  }

  // Centralized method to encode responses to JSON
  String _encodeResponse(String status, dynamic data) {
    return jsonEncode({'status': status, 'data': data});
  }

  // Test PIN method, with detailed JSON response
  String _testPin(List<String> parts) {
    if (parts.length != 3) {
      getIt<AppLogger>().logWarning('TESTPIN: Nombre d’arguments incorrect.');
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    final pinCode = int.tryParse(parts[2]);

    if (accountNumber == null || pinCode == null) {
      getIt<AppLogger>().logWarning(
        'TESTPIN: Conversion invalide pour accountNumber ou pinCode.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final result = _database.select(
      'SELECT PIN, NumeroClient FROM comptes WHERE NumeroCompte = ?',
      [accountNumber],
    );

    if (result.isNotEmpty && result.first['PIN'] == pinCode) {
      final clientResult = _database.select(
        'SELECT Nom, Prenom, Adresse FROM clients WHERE NumeroClient = ?',
        [result.first['NumeroClient']],
      );

      if (clientResult.isNotEmpty) {
        final user = {
          'account_number': accountNumber,
          'name': clientResult.first['Nom'],
          'surname': clientResult.first['Prenom'],
          'address': clientResult.first['Adresse'],
        };
        getIt<AppLogger>().logInfo(
          'TESTPIN réussi pour le compte $accountNumber',
        );
        return _encodeResponse(AppResponse.testPinOk, user);
      }
    }
    getIt<AppLogger>().logWarning(
      'TESTPIN échoué pour le compte $accountNumber',
    );
    return _encodeResponse(AppResponse.testPinNok, null);
  }

  // Withdraw money method with operation recording
  String _withdraw(List<String> parts) {
    if (parts.length != 3) {
      getIt<AppLogger>().logWarning('WITHDRAW: Nombre d’arguments incorrect.');
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    final amount = double.tryParse(parts[2]);

    if (accountNumber == null || amount == null) {
      getIt<AppLogger>().logWarning(
        'WITHDRAW: Conversion invalide pour accountNumber ou amount.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final balance = _getBalance(accountNumber);

    if (balance >= amount) {
      _database.execute(
        'UPDATE comptes SET Solde = Solde - ? WHERE NumeroCompte = ?',
        [amount, accountNumber],
      );
      _recordOperation(accountNumber, 'Withdrawal', amount);
      getIt<AppLogger>().logInfo(
        'Retrait de $amount effectué sur le compte $accountNumber',
      );
      return _encodeResponse(AppResponse.withdrawOk, null);
    }
    getIt<AppLogger>().logWarning(
      'WITHDRAW: Solde insuffisant pour le compte $accountNumber',
    );
    return _encodeResponse(AppResponse.withdrawNok, "Montant insuffisant");
  }

  // Deposit money method with operation recording
  String _deposit(List<String> parts) {
    if (parts.length != 3) {
      getIt<AppLogger>().logWarning('DEPOSIT: Nombre d’arguments incorrect.');
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    final amount = double.tryParse(parts[2]);

    if (accountNumber == null || amount == null) {
      getIt<AppLogger>().logWarning(
        'DEPOSIT: Conversion invalide pour accountNumber ou amount.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    _database.execute(
      'UPDATE comptes SET Solde = Solde + ? WHERE NumeroCompte = ?',
      [amount, accountNumber],
    );
    _recordOperation(accountNumber, 'Deposit', amount);
    getIt<AppLogger>().logInfo(
      'Dépôt de $amount effectué sur le compte $accountNumber',
    );
    return _encodeResponse(AppResponse.depositOk, null);
  }

  // Transfer money method with operation recording
  String _transfer(List<String> parts) {
    if (parts.length != 4) {
      getIt<AppLogger>().logWarning('TRANSFER: Nombre d’arguments incorrect.');
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountSrc = int.tryParse(parts[1]);
    final accountDest = int.tryParse(parts[2]);
    final amount = double.tryParse(parts[3]);

    if (accountSrc == null || accountDest == null || amount == null) {
      getIt<AppLogger>().logWarning(
        'TRANSFER: Conversion invalide pour accountSrc, accountDest ou amount.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final balance = _getBalance(accountSrc);

    if (balance >= amount) {
      _database.execute(
        'UPDATE comptes SET Solde = Solde - ? WHERE NumeroCompte = ?',
        [amount, accountSrc],
      );
      _database.execute(
        'UPDATE comptes SET Solde = Solde + ? WHERE NumeroCompte = ?',
        [amount, accountDest],
      );
      _recordOperation(accountSrc, 'Transfer to $accountDest', amount);
      _recordOperation(
        accountDest,
        'Transfer received from $accountSrc',
        amount,
      );
      getIt<AppLogger>().logInfo(
        'Transfert de $amount de $accountSrc vers $accountDest effectué.',
      );
      return _encodeResponse(AppResponse.tranferOk, null);
    }
    getIt<AppLogger>().logWarning(
      'TRANSFER: Solde insuffisant pour le compte $accountSrc',
    );
    return _encodeResponse(AppResponse.tranferNok, 'Montant insuffisant');
  }

  // Get balance of an account
  String _balance(List<String> parts) {
    if (parts.length != 2) {
      getIt<AppLogger>().logWarning('BALANCE: Nombre d’arguments incorrect.');
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    if (accountNumber == null) {
      getIt<AppLogger>().logWarning(
        'BALANCE: Conversion invalide pour accountNumber.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final balance = _getBalance(accountNumber);
    getIt<AppLogger>().logInfo('Balance du compte $accountNumber: $balance');
    return balance > 0.0
        ? _encodeResponse(AppResponse.balanceOk, balance)
        : _encodeResponse(AppResponse.errOperation, null);
  }

  // Get account operation history in JSON format
  String _history(List<String> parts) {
    if (parts.length != 2) {
      getIt<AppLogger>().logWarning('HISTORY: Nombre d’arguments incorrect.');
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    if (accountNumber == null) {
      getIt<AppLogger>().logWarning(
        'HISTORY: Conversion invalide pour accountNumber.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final result = _database.select(
      'SELECT DateOperation, LibelleOperation, Montant FROM operations WHERE NumeroCompte = ? ORDER BY DateOperation DESC LIMIT 10',
      [accountNumber],
    );

    if (result.isEmpty) {
      getIt<AppLogger>().logInfo(
        'HISTORY: Aucune opération pour le compte $accountNumber.',
      );
      return _encodeResponse(AppResponse.history, []);
    }

    final history =
        result.map((row) {
          return {
            'date': row['DateOperation'],
            'libelle': row['LibelleOperation'],
            'montant': row['Montant'],
          };
        }).toList();

    getIt<AppLogger>().logInfo(
      'HISTORY: Historique récupéré pour le compte $accountNumber.',
    );
    return _encodeResponse(AppResponse.history, history);
  }

  // Get account operations and generate csv file.
  String _historyCSV(List<String> parts) {
    if (parts.length != 2) {
      getIt<AppLogger>().logWarning(
        'HISTORY_CSV: Nombre d’arguments incorrect.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    if (accountNumber == null) {
      getIt<AppLogger>().logWarning(
        'HISTORY_CSV: Conversion invalide pour accountNumber.',
      );
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final result = _database.select(
      'SELECT DateOperation, LibelleOperation, Montant FROM operations WHERE NumeroCompte = ? ORDER BY DateOperation DESC LIMIT 10',
      [accountNumber],
    );

    if (result.isEmpty) {
      getIt<AppLogger>().logInfo(
        'HISTORY_CSV: Aucune opération pour le compte $accountNumber.',
      );
      return _encodeResponse(AppResponse.history, []);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '_');
    final fileName = 'history_csv_${accountNumber}_$timestamp.csv';
    final filePath = '${getIt<AppConfig>().fileServerPath}/$fileName';
    final file = File(filePath);

    final List<List<dynamic>> csvData = [
      ['Date', 'Libelle', 'Montant'],
      ...result.map(
        (row) => [
          row['DateOperation'],
          row['LibelleOperation'],
          row['Montant'],
        ],
      ),
    ];

    final csvConverter = ListToCsvConverter();
    final csvString = csvConverter.convert(csvData);

    file.writeAsStringSync(csvString);
    getIt<AppLogger>().logInfo(
      'HISTORY_CSV: Fichier CSV généré pour le compte $accountNumber: $filePath',
    );
    return _encodeResponse(AppResponse.history, filePath);
  }

  // Téléchargement d'un fichier: lit le fichier et renvoie son contenu encodé en base64.
  String _downloadFile(List<String> parts) {
    if (parts.length != 2) {
      getIt<AppLogger>().logWarning('DOWNLOAD: Nombre d’arguments incorrect.');
      return _encodeResponse(AppResponse.errOperation, null);
    }
    final filePath = parts[1];
    final file = File(filePath);
    if (!file.existsSync()) {
      getIt<AppLogger>().logWarning('DOWNLOAD: Fichier non trouvé: $filePath');
      return _encodeResponse(AppResponse.errOperation, 'File not found');
    }
    try {
      final fileBytes = file.readAsBytesSync();
      final base64Content = base64Encode(fileBytes);
      getIt<AppLogger>().logInfo(
        'DOWNLOAD: Fichier $filePath envoyé avec succès.',
      );
      return _encodeResponse(AppResponse.downloadOk, {
        'file_name': file.uri.pathSegments.last,
        'file_content': base64Content,
      });
    } catch (e) {
      getIt<AppLogger>().logError(
        'DOWNLOAD: Échec de transfert du fichier: $e',
      );
      return _encodeResponse(
        AppResponse.errOperation,
        'File transfer failed: $e',
      );
    }
  }

  // Process the operation based on the request
  String processOperation(String request) {
    final parts = request.split(' ');
    if (parts.isEmpty) {
      getIt<AppLogger>().logWarning('PROCESS: Commande vide reçue.');
      return _encodeResponse(AppResponse.errOperation, null);
    }

    switch (parts[0]) {
      case 'TESTPIN':
        return _testPin(parts);
      case 'WITHDRAW':
        return _withdraw(parts);
      case 'DEPOSIT':
        return _deposit(parts);
      case 'TRANSFER':
        return _transfer(parts);
      case 'HISTORY':
        return _history(parts);
      case 'HISTORY_CSV':
        return _historyCSV(parts);
      case 'BALANCE':
        return _balance(parts);
      case 'DOWNLOAD':
        return _downloadFile(parts);
      default:
        getIt<AppLogger>().logWarning(
          'PROCESS: Commande inconnue: ${parts[0]}',
        );
        return _encodeResponse(AppResponse.errOperation, null);
    }
  }
}

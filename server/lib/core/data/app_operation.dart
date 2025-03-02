import 'dart:convert';
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
    return result.isNotEmpty ? result.first['Solde'] : 0.0;
  }

  // Utility method to record an operation in the 'operations' table
  void _recordOperation(int accountNumber, String libelle, double montant) {
    _database.execute(
      'INSERT INTO operations (NumeroCompte, DateOperation, LibelleOperation, Montant) VALUES (?, ?, ?, ?)',
      [accountNumber, DateTime.now().toIso8601String(), libelle, montant],
    );
  }

  // Centralized method to encode responses to JSON
  String _encodeResponse(String status, dynamic data) {
    return jsonEncode({'status': status, 'data': data});
  }

  // Test PIN method, with detailed JSON response
  String _testPin(List<String> parts) {
    if (parts.length != 3) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    final pinCode = int.tryParse(parts[2]);

    if (accountNumber == null || pinCode == null) {
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
          'accountNumber': accountNumber,
          'name': clientResult.first['Nom'],
          'surname': clientResult.first['Prenom'],
          'address': clientResult.first['Adresse'],
        };
        return _encodeResponse(AppResponse.testPinOk, user);
      }
    }
    return _encodeResponse(AppResponse.testPinNok, null);
  }

  // Withdraw money method with operation recording
  String _withdraw(List<String> parts) {
    if (parts.length != 3) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    final amount = double.tryParse(parts[2]);

    if (accountNumber == null || amount == null) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final balance = _getBalance(accountNumber);

    if (balance >= amount) {
      _database.execute(
        'UPDATE comptes SET Solde = Solde - ? WHERE NumeroCompte = ?',
        [amount, accountNumber],
      );
      _recordOperation(accountNumber, 'Withdrawal', amount);
      return _encodeResponse(AppResponse.withdrawOk, null);
    }
    return _encodeResponse(AppResponse.withdrawNok, null);
  }

  // Deposit money method with operation recording
  String _deposit(List<String> parts) {
    if (parts.length != 3) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    final amount = double.tryParse(parts[2]);

    if (accountNumber == null || amount == null) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    _database.execute(
      'UPDATE comptes SET Solde = Solde + ? WHERE NumeroCompte = ?',
      [amount, accountNumber],
    );
    _recordOperation(accountNumber, 'Deposit', amount);
    return _encodeResponse(AppResponse.depositOk, null);
  }

  // Transfer money method with operation recording
  String _transfer(List<String> parts) {
    if (parts.length != 4) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountSrc = int.tryParse(parts[1]);
    final accountDest = int.tryParse(parts[2]);
    final amount = double.tryParse(parts[3]);

    if (accountSrc == null || accountDest == null || amount == null) {
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
      return _encodeResponse(AppResponse.tranferOk, null);
    }
    return _encodeResponse(AppResponse.tranferNok, null);
  }

  // Get balance of an account
  String _balance(List<String> parts) {
    if (parts.length != 2) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    if (accountNumber == null) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final balance = _getBalance(accountNumber);
    return balance > 0.0
        ? _encodeResponse(AppResponse.balanceOk, balance)
        : _encodeResponse(AppResponse.errOperation, null);
  }

  // Get account operation history in JSON format
  String _history(List<String> parts) {
    if (parts.length != 2) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final accountNumber = int.tryParse(parts[1]);
    if (accountNumber == null) {
      return _encodeResponse(AppResponse.errOperation, null);
    }

    final result = _database.select(
      'SELECT DateOperation, LibelleOperation, Montant FROM operations WHERE NumeroCompte = ? ORDER BY DateOperation DESC LIMIT 10',
      [accountNumber],
    );

    if (result.isEmpty) return _encodeResponse(AppResponse.errOperation, null);

    final history =
        result.map((row) {
          return {
            'date': row['DateOperation'],
            'libelle': row['LibelleOperation'],
            'montant': row['Montant'],
          };
        }).toList();

    return _encodeResponse(AppResponse.history, history);
  }

  // Process the operation based on the request
  String processOperation(String request) {
    final parts = request.split(' ');
    if (parts.isEmpty) return _encodeResponse(AppResponse.errOperation, null);

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
      case 'BALANCE':
        return _balance(parts);
      default:
        return _encodeResponse(AppResponse.errOperation, null);
    }
  }
}

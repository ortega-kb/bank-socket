import 'dart:io';

import 'package:client/core/app_logger.dart';
import 'package:client/core/config/config.dart';
import 'package:client/core/data/client_repository.dart';
import 'package:client/core/data/client_repository_impl.dart';
import 'package:client/core/security.dart';
import 'package:client/feature/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/deposit/deposit_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/transfer/transfer_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/withdraw/withdraw_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/web.dart';

final getIt = GetIt.asNewInstance();

Future<void> initializeApp() async {
  getIt.registerLazySingleton(() => Logger());

  final config = Config(DotEnv()..load());
  getIt.registerLazySingleton(() => config);

  getIt.registerLazySingleton(() => AppLogger(Logger()));

  final securityContext = await Security.instance.context();
  getIt.registerSingleton<SecurityContext>(securityContext);

  final serverHost = config.serverHost;
  final serverPort = int.parse(config.serverPort);

  // Secure socket client
  final socketClient = await SecureSocket.connect(
    serverHost,
    serverPort,
    context: securityContext,
  );
  getIt.registerSingleton<SecureSocket>(socketClient);
  getIt.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(getIt()),
  );
  _initializeAuth();
  _initializeDashboard();
}

void _initializeAuth() async {
  getIt.registerFactory(() => AuthBloc(getIt()));
}

void _initializeDashboard() async {
  getIt.registerFactory(() => DashboardBloc(getIt()));
  getIt.registerFactory(() => WithdrawBloc(getIt()));
  getIt.registerFactory(() => DepositBloc(getIt()));
  getIt.registerFactory(() => TransferBloc(getIt()));
}

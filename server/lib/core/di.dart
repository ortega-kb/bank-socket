import 'package:dotenv/dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/web.dart';
import 'package:server/core/data/app_database.dart';
import 'package:server/core/app_logger.dart';
import 'package:server/core/config/app_config.dart';
import 'package:server/core/data/app_operation.dart';
import 'package:server/core/security.dart';

final getIt = GetIt.asNewInstance();

Future<void> initializeApp() async {
  final dotEnv = DotEnv()..load();
  getIt.registerLazySingleton(() => AppConfig(dotEnv));

  getIt.registerLazySingleton(() => AppLogger(Logger()));
  getIt.registerLazySingleton(() => Security.instance);

  getIt.registerLazySingleton(() => AppOperation(AppDatabase.database));
}

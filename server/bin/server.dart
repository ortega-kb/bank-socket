import 'package:server/core/data/app_operation.dart';
import 'package:server/core/di.dart';
import 'package:server/server.dart';

void main(List<String> arguments) async {
  await initializeApp();
  final server = Server(getIt<AppOperation>());

  server.run();
}

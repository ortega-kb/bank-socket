import 'package:server/core/di.dart';
import 'package:server/server.dart';

void main(List<String> arguments) async {
  await initializeApp();
  final server = Server();

  server.run();
}

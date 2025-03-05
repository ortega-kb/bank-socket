import 'package:client/core/app.dart';
import 'package:client/core/app_bloc_observer.dart';
import 'package:client/core/config/app_router_config.dart'; 
import 'package:client/core/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();

  Bloc.observer = AppBlocObserver();
  runApp(App(router: AppRouterConfig.router));
}

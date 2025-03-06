import 'package:client/core/data/models/account.dart';
import 'package:client/core/di.dart';
import 'package:client/feature/auth/presentation/bloc/register/register_bloc.dart';
import 'package:client/feature/auth/presentation/screen/register_screen.dart';
import 'package:client/feature/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/deposit/deposit_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/download/download_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/transfer/transfer_bloc.dart';
import 'package:client/feature/dashboard/presentation/bloc/withdraw/withdraw_bloc.dart';
import 'package:client/feature/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:client/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:client/feature/auth/presentation/screen/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class AppRouterConfig {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: LoginScreen.route,
    routes: [
      GoRoute(
        path: LoginScreen.path,
        builder: (_, state) {
          return BlocProvider(
            create: (context) => getIt<AuthBloc>(),
            child: LoginScreen(),
          );
        },
        routes: [
          GoRoute(
            path: RegisterScreen.path,
            builder:
                (context, state) => BlocProvider(
                  create: (context) => getIt<RegisterBloc>(),
                  child: RegisterScreen(),
                ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoot.path,
        builder: (_, state) {
          final account = Account.fromJson(state.extra as Map<String, dynamic>);

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<DashboardBloc>()),
              BlocProvider(create: (context) => getIt<WithdrawBloc>()),
              BlocProvider(create: (context) => getIt<DepositBloc>()),
              BlocProvider(create: (context) => getIt<TransferBloc>()),
              BlocProvider(create: (context) => getIt<DownloadBloc>()),
            ],
            child: AppRoot(account: account),
          );
        },
      ),
    ],
  );
}

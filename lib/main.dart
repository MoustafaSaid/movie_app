import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'presentation/cubit/theme_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/config/sentry_config.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection
  await initDependencyInjection();

  // Initialize Sentry
  await SentryFlutter.init((options) {
    options.dsn =
        SentryConfig.dsn.isNotEmpty &&
            SentryConfig.dsn !=
                'https://9a7b659bf8d016a3f2a7e751fd55d1c9@o4510286608859136.ingest.us.sentry.io/4510286610104325'
        ? SentryConfig.dsn
        : null; // Only init if DSN is provided
    options.tracesSampleRate = 1.0;
    options.environment = 'production';
  }, appRunner: () => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Movie App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}

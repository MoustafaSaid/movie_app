import 'package:sentry_flutter/sentry_flutter.dart';

class SentryConfig {
  static const String dsn = 'YOUR_SENTRY_DSN_HERE'; // Replace with your Sentry DSN

  static Future<void> init() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 1.0;
        options.environment = 'production';
      },
      appRunner: () {}, // This will be overridden in main.dart
    );
  }
}


/// Compile-time configuration & flavor switches.
///
/// Values are fixed at build time via `--dart-define`, so a single codebase
/// can produce dev / staging / prod binaries.
class AppConfig {
  AppConfig._();

  /// Display name of the app.
  static const String appName = 'Latelogic';

  /// Active environment: `dev` | `staging` | `prod`.
  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static bool get isProd => env == 'prod';
  static bool get isDev => env == 'dev';
}

import 'package:flutter/material.dart';

import '../services/storage_service.dart';

/// Owns the app's [ThemeMode]. Colors switch reactively via the theme's
/// [AppPalette] extension (read with `context.c`), so toggling rebuilds the
/// whole tree — const widgets included.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeProvider() {
    final saved = StorageService.getString(StorageService.kThemeMode);
    if (saved == 'dark') _mode = ThemeMode.dark;
  }

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() => setDark(!isDark);

  void setDark(bool dark) {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    StorageService.setString(
      StorageService.kThemeMode,
      dark ? 'dark' : 'light',
    );
    notifyListeners();
  }
}

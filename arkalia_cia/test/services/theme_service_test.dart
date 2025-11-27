import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeService', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
    });

    test('getTheme should return system theme by default', () async {
      final theme = await ThemeService.getTheme();
      expect(theme, 'system');
    });

    test('setTheme should update theme', () async {
      await ThemeService.setTheme('light');
      expect(await ThemeService.getTheme(), 'light');

      await ThemeService.setTheme('dark');
      expect(await ThemeService.getTheme(), 'dark');

      await ThemeService.setTheme('system');
      expect(await ThemeService.getTheme(), 'system');
    });

    test('getThemeMode should return correct ThemeMode', () async {
      await ThemeService.setTheme('light');
      expect(await ThemeService.getThemeMode(), ThemeMode.light);

      await ThemeService.setTheme('dark');
      expect(await ThemeService.getThemeMode(), ThemeMode.dark);

      await ThemeService.setTheme('system');
      expect(await ThemeService.getThemeMode(), ThemeMode.system);
    });

    test('getThemeData should return light theme for light mode', () {
      final themeData = ThemeService.getThemeData('light', Brightness.light);
      expect(themeData.brightness, Brightness.light);
    });

    test('getThemeData should return dark theme for dark mode', () {
      final themeData = ThemeService.getThemeData('dark', Brightness.light);
      expect(themeData.brightness, Brightness.dark);
    });

    test('getThemeData should return dark theme for system mode when system is dark', () {
      final themeData = ThemeService.getThemeData('system', Brightness.dark);
      expect(themeData.brightness, Brightness.dark);
    });

    test('getThemeData should return light theme for system mode when system is light', () {
      final themeData = ThemeService.getThemeData('system', Brightness.light);
      expect(themeData.brightness, Brightness.light);
    });
  });
}


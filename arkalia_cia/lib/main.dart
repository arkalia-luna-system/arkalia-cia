import 'package:flutter/material.dart';
import 'screens/lock_screen.dart';
import 'services/local_storage_service.dart';
import 'services/calendar_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await CalendarService.init();
  runApp(const ArkaliaCIAApp());
}

class ArkaliaCIAApp extends StatefulWidget {
  const ArkaliaCIAApp({super.key});

  @override
  State<ArkaliaCIAApp> createState() => _ArkaliaCIAAppState();
}

class _ArkaliaCIAAppState extends State<ArkaliaCIAApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeMode = await ThemeService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkalia CIA',
      theme: ThemeService.getThemeData('light', MediaQuery.platformBrightnessOf(context)),
      darkTheme: ThemeService.getThemeData('dark', Brightness.dark),
      themeMode: _themeMode,
      home: const LockScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'services/local_storage_service.dart';
import 'services/calendar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await CalendarService.init();
  runApp(const ArkaliaCIAApp());
}

class ArkaliaCIAApp extends StatelessWidget {
  const ArkaliaCIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkalia CIA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

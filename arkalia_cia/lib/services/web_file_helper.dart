// Fichier d'export conditionnel pour web_file_helper
// Par défaut (tests/mobile) : exporte web_file_helper_stub.dart
// Si dart.library.html est disponible (web) : exporte web_file_helper_web.dart
export 'web_file_helper_stub.dart' if (dart.library.html) 'web_file_helper_web.dart';

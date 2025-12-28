// Fichier d'export conditionnel pour web_file_helper
// Utilise le stub pour tests/mobile, et la version web pour le web
export 'web_file_helper_stub.dart' if (dart.library.html) 'web_file_helper_web.dart';

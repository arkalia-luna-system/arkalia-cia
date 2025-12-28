// Stub pour dart:html utilisé uniquement pour éviter erreurs compilation web
// Ce fichier n'est jamais réellement utilisé car le code est protégé par kIsWeb
// ignore_for_file: unused_import, unused_element, avoid_types_on_closure_parameters

/// Stub pour File de dart:html (jamais utilisé)
/// Compatible avec dart:io.File pour éviter erreurs compilation
class File {
  final String _path;
  
  File(this._path, [dynamic mimeType]) {
    // Ne jamais être appelé sur web (code protégé par kIsWeb)
  }
  
  Future<bool> exists() async {
    throw UnsupportedError('File.exists stub - ne doit jamais être appelé');
  }
  
  String get path => _path;
  
  Future<int> length() async {
    throw UnsupportedError('File.length stub - ne doit jamais être appelé');
  }
}

/// Stub pour Platform de dart:html (jamais utilisé)
class Platform {
  static bool get isAndroid => throw UnsupportedError('Platform.isAndroid stub - ne doit jamais être appelé');
  static bool get isIOS => throw UnsupportedError('Platform.isIOS stub - ne doit jamais être appelé');
}


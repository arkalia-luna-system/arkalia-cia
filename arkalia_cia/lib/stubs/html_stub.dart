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

/// Stub pour Directory de dart:io (jamais utilisé)
class Directory {
  final String path;
  
  Directory(this.path);
  
  Future<bool> exists() async {
    throw UnsupportedError('Directory.exists stub - ne doit jamais être appelé');
  }
  
  Future<Directory> create({bool recursive = false}) async {
    throw UnsupportedError('Directory.create stub - ne doit jamais être appelé');
  }
  
  Stream<FileSystemEntity> list() {
    throw UnsupportedError('Directory.list stub - ne doit jamais être appelé');
  }
}

/// Stub pour FileSystemEntity de dart:io (jamais utilisé)
abstract class FileSystemEntity {
  String get path => throw UnsupportedError('FileSystemEntity.path stub - ne doit jamais être appelé');
}

/// Stub pour Platform de dart:html (jamais utilisé)
class Platform {
  static bool get isAndroid => throw UnsupportedError('Platform.isAndroid stub - ne doit jamais être appelé');
  static bool get isIOS => throw UnsupportedError('Platform.isIOS stub - ne doit jamais être appelé');
}


import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Import conditionnel pour éviter conflit avec stub web
import 'dart:io' if (dart.library.html) '../stubs/html_stub.dart' as io;

/// Service de gestion des fichiers avec path_provider
class FileStorageService {
  /// Récupère le répertoire documents de l'application
  static Future<io.Directory> getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final documentsDir = io.Directory(path.join(appDir.path, 'arkalia_cia', 'documents'));
    
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    
    return documentsDir;
  }

  /// Récupère le répertoire temporaire
  static Future<io.Directory> getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final arkaliaTempDir = io.Directory(path.join(tempDir.path, 'arkalia_cia'));
    
    if (!await arkaliaTempDir.exists()) {
      await arkaliaTempDir.create(recursive: true);
    }
    
    return arkaliaTempDir;
  }

  /// Copie un fichier vers le répertoire documents
  static Future<io.File> copyToDocumentsDirectory(io.File sourceFile, String fileName) async {
    final documentsDir = await getDocumentsDirectory();
    final destFile = io.File(path.join(documentsDir.path, fileName));
    
    return await sourceFile.copy(destFile.path);
  }

  /// Supprime un fichier du répertoire documents
  static Future<bool> deleteDocumentFile(String fileName) async {
    try {
      final documentsDir = await getDocumentsDirectory();
      final file = io.File(path.join(documentsDir.path, fileName));
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Récupère le chemin complet d'un fichier document
  static Future<String> getDocumentPath(String fileName) async {
    final documentsDir = await getDocumentsDirectory();
    return path.join(documentsDir.path, fileName);
  }

  /// Liste tous les fichiers dans le répertoire documents
  static Future<List<io.FileSystemEntity>> listDocumentFiles() async {
    final documentsDir = await getDocumentsDirectory();
    return documentsDir.list().toList();
  }

  /// Vérifie si un fichier existe dans le répertoire documents
  static Future<bool> documentExists(String fileName) async {
    final documentsDir = await getDocumentsDirectory();
    final file = io.File(path.join(documentsDir.path, fileName));
    return await file.exists();
  }

  /// Sauvegarde des bytes vers le répertoire documents (pour le web)
  static Future<io.File> saveBytesToDocumentsDirectory(
    Uint8List bytes,
    String fileName,
  ) async {
    if (kIsWeb) {
      // Sur le web, on ne peut pas utiliser File directement
      // On stocke les bytes dans SharedPreferences ou on utilise un autre mécanisme
      // Pour l'instant, on retourne une erreur car le web nécessite une approche différente
      throw UnsupportedError(
        'saveBytesToDocumentsDirectory n\'est pas supporté sur le web. '
        'Utilisez LocalStorageService pour stocker les données.',
      );
    }
    
    final documentsDir = await getDocumentsDirectory();
    final destFile = io.File(path.join(documentsDir.path, fileName));
    await destFile.writeAsBytes(bytes);
    return destFile;
  }
}


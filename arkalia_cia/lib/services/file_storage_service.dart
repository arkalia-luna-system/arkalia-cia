import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service de gestion des fichiers avec path_provider
class FileStorageService {
  /// Récupère le répertoire documents de l'application
  static Future<Directory> getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final documentsDir = Directory(path.join(appDir.path, 'arkalia_cia', 'documents'));
    
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    
    return documentsDir;
  }

  /// Récupère le répertoire temporaire
  static Future<Directory> getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final arkaliaTempDir = Directory(path.join(tempDir.path, 'arkalia_cia'));
    
    if (!await arkaliaTempDir.exists()) {
      await arkaliaTempDir.create(recursive: true);
    }
    
    return arkaliaTempDir;
  }

  /// Copie un fichier vers le répertoire documents
  static Future<File> copyToDocumentsDirectory(File sourceFile, String fileName) async {
    final documentsDir = await getDocumentsDirectory();
    final destFile = File(path.join(documentsDir.path, fileName));
    
    return await sourceFile.copy(destFile.path);
  }

  /// Supprime un fichier du répertoire documents
  static Future<bool> deleteDocumentFile(String fileName) async {
    try {
      final documentsDir = await getDocumentsDirectory();
      final file = File(path.join(documentsDir.path, fileName));
      
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
  static Future<List<FileSystemEntity>> listDocumentFiles() async {
    final documentsDir = await getDocumentsDirectory();
    return documentsDir.list().toList();
  }

  /// Vérifie si un fichier existe dans le répertoire documents
  static Future<bool> documentExists(String fileName) async {
    final documentsDir = await getDocumentsDirectory();
    final file = File(path.join(documentsDir.path, fileName));
    return await file.exists();
  }

  /// Sauvegarde des bytes vers le répertoire documents (pour le web)
  static Future<File> saveBytesToDocumentsDirectory(
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
    final destFile = File(path.join(documentsDir.path, fileName));
    await destFile.writeAsBytes(bytes);
    return destFile;
  }
}


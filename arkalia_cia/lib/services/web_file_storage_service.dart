import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service de stockage des bytes de fichiers sur web
/// Utilise SharedPreferences avec une clé par fichier
/// Limite: 5MB par fichier (limite raisonnable pour la plupart des PDFs médicaux)
class WebFileStorageService {
  static const String _prefix = 'doc_bytes_';
  static const int _maxFileSize = 5 * 1024 * 1024; // 5 MB

  /// Sauvegarde les bytes d'un fichier
  /// Retourne true si sauvegardé, false si trop volumineux
  static Future<bool> saveFileBytes(String fileId, Uint8List bytes) async {
    if (!kIsWeb) {
      return false; // Ne fonctionne que sur web
    }

    // Vérifier la taille
    if (bytes.length > _maxFileSize) {
      return false; // Fichier trop volumineux
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // Convertir les bytes en base64 pour stockage
      final base64String = base64Encode(bytes);
      return await prefs.setString('$_prefix$fileId', base64String);
    } catch (e) {
      return false;
    }
  }

  /// Récupère les bytes d'un fichier
  /// Retourne null si le fichier n'existe pas ou est trop volumineux
  static Future<Uint8List?> getFileBytes(String fileId) async {
    if (!kIsWeb) {
      return null; // Ne fonctionne que sur web
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString('$_prefix$fileId');
      
      if (base64String == null) {
        return null;
      }

      // Décoder depuis base64
      final bytes = base64Decode(base64String);
      return Uint8List.fromList(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Supprime les bytes d'un fichier
  static Future<bool> deleteFileBytes(String fileId) async {
    if (!kIsWeb) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('$_prefix$fileId');
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un fichier existe
  static Future<bool> fileBytesExist(String fileId) async {
    if (!kIsWeb) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_prefix$fileId');
    } catch (e) {
      return false;
    }
  }

  /// Retourne la taille maximale autorisée
  static int get maxFileSize => _maxFileSize;
}


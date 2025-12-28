import 'package:flutter/foundation.dart';
import 'dart:typed_data';

/// Stub pour web_file_helper (utilisé lors des tests/mobile)
/// Les fonctions retournent null car elles ne sont jamais appelées (protégé par kIsWeb)

/// Helper pour créer un Blob URL sur web
/// Retourne null si pas sur web ou en cas d'erreur
String? createBlobUrl(Uint8List bytes, String mimeType) {
  // Ne sera jamais appelé car protégé par kIsWeb
  return null;
}

/// Révoque un Blob URL
void revokeBlobUrl(String url) {
  // Ne sera jamais appelé car protégé par kIsWeb
}


import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
// Ce fichier n'est exporté que sur web (via export conditionnel dans web_file_helper.dart)
// Donc dart:html est toujours disponible ici
import 'dart:html' as html;

/// Helper pour créer un Blob URL sur web
/// Retourne null si pas sur web ou en cas d'erreur
String? createBlobUrl(Uint8List bytes, String mimeType) {
  if (!kIsWeb) return null;
  
  try {
    final blob = html.Blob([bytes], mimeType);
    return html.Url.createObjectUrlFromBlob(blob);
  } catch (e) {
    return null;
  }
}

/// Révoque un Blob URL
void revokeBlobUrl(String url) {
  if (!kIsWeb) return;
  
  try {
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    // Ignorer les erreurs
  }
}


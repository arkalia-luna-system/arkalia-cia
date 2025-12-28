import 'package:flutter/foundation.dart';

// Import conditionnel pour dart:html (uniquement sur web)
// Sur mobile/tests, utiliser le stub
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html if (dart.library.io) '../stubs/html_stub.dart';

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


import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/error_helper.dart';
import '../utils/app_logger.dart';
import 'backend_config_service.dart';
import 'auth_api_service.dart';

/// Service pour importer des documents depuis portails santé (import manuel)
/// Stratégie gratuite : Utilisateur exporte PDF depuis portail, puis upload ici
class HealthPortalImportService {
  /// Upload un PDF depuis un portail santé (Andaman 7 ou MaSanté)
  /// 
  /// Args:
  ///   - file: Fichier PDF à uploader
  ///   - portal: 'andaman7' ou 'masante'
  ///   - onProgress: Callback pour progression upload (0.0 à 1.0)
  /// 
  /// Returns:
  ///   - Map avec 'success', 'imported_count', 'message', etc.
  static Future<Map<String, dynamic>> uploadPortalPDF(
    File file, {
    required String portal,
    Function(double)? onProgress,
  }) async {
    try {
      final baseUrl = await BackendConfigService.getBackendURL();
      if (baseUrl.isEmpty) {
        return {
          'success': false,
          'error': 'Backend non configuré',
          'backend_not_configured': true,
        };
      }

      // Validation portail
      final portalLower = portal.toLowerCase();
      if (portalLower != 'andaman7' && portalLower != 'masante') {
        return {
          'success': false,
          'error': 'Portail invalide. Utilisez "andaman7" ou "masante"',
        };
      }

      // Validation fichier
      if (!await file.exists()) {
        return {
          'success': false,
          'error': 'Fichier non trouvé',
        };
      }

      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        return {
          'success': false,
          'error': 'Fichier trop volumineux (max 50MB)',
        };
      }

      // Préparer requête multipart
      final uri = Uri.parse('$baseUrl/api/v1/health-portals/import/manual');
      
      // Récupérer token JWT
      final token = await AuthApiService.getAccessToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Créer requête multipart
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      
      // Ajouter fichier
      final fileStream = file.openRead();
      final fileLength = fileSize;
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: MediaType('application', 'pdf'),
      );
      request.files.add(multipartFile);
      
      // Ajouter paramètre portail
      request.fields['portal'] = portalLower;

      // Envoyer requête avec suivi progression
      final streamedResponse = await request.send();
      
      // Lire réponse
      final response = await http.Response.fromStream(streamedResponse);
      
      // Parser réponse
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Import portail réussi: ${data['imported_count']} document(s)');
        return {
          'success': true,
          ...data,
        };
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorData?['detail'] ?? 'Erreur lors de l\'import';
        ErrorHelper.logError('HealthPortalImportService.uploadPortalPDF', errorMessage);
        return {
          'success': false,
          'error': ErrorHelper.getUserFriendlyMessage(errorMessage),
        };
      }
    } catch (e) {
      ErrorHelper.logError('HealthPortalImportService.uploadPortalPDF', e);
      return {
        'success': false,
        'error': ErrorHelper.getUserFriendlyMessage(e),
      };
    }
  }
}


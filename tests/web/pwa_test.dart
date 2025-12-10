// Tests pour la PWA Arkalia CIA
// Date: 10 décembre 2025

import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  group('PWA Configuration Tests', () {
    test('manifest.json existe et est valide', () {
      // Chercher le fichier depuis différents chemins possibles
      File? manifestFile;
      final paths = [
        'arkalia_cia/web/manifest.json',
        '../arkalia_cia/web/manifest.json',
        '../../arkalia_cia/web/manifest.json',
      ];
      
      for (final path in paths) {
        final file = File(path);
        if (file.existsSync()) {
          manifestFile = file;
          break;
        }
      }
      
      expect(manifestFile, isNotNull, 
        reason: 'manifest.json doit exister dans arkalia_cia/web/');
      
      final manifestContent = manifestFile!.readAsStringSync();
      final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;

      // Vérifier les champs requis
      expect(manifest['name'], isNotNull, 
        reason: 'manifest.json doit avoir un nom');
      expect(manifest['short_name'], isNotNull, 
        reason: 'manifest.json doit avoir un short_name');
      expect(manifest['start_url'], isNotNull, 
        reason: 'manifest.json doit avoir un start_url');
      expect(manifest['display'], equals('standalone'), 
        reason: 'manifest.json doit avoir display: standalone');
      expect(manifest['icons'], isA<List>(), 
        reason: 'manifest.json doit avoir des icônes');
      
      // Vérifier qu'il y a au moins une icône
      final icons = manifest['icons'] as List;
      expect(icons.isNotEmpty, isTrue, 
        reason: 'manifest.json doit avoir au moins une icône');
    });

    test('index.html existe et référence manifest.json', () {
      File? indexFile;
      final paths = [
        'arkalia_cia/web/index.html',
        '../arkalia_cia/web/index.html',
        '../../arkalia_cia/web/index.html',
      ];
      
      for (final path in paths) {
        final file = File(path);
        if (file.existsSync()) {
          indexFile = file;
          break;
        }
      }
      
      expect(indexFile, isNotNull, 
        reason: 'index.html doit exister dans arkalia_cia/web/');

      final indexContent = indexFile!.readAsStringSync();
      
      // Vérifier que manifest.json est référencé
      expect(indexContent.contains('manifest.json'), isTrue, 
        reason: 'index.html doit référencer manifest.json');
      
      // Vérifier que le service worker est enregistré
      expect(indexContent.contains('serviceWorker'), isTrue, 
        reason: 'index.html doit enregistrer le service worker');
    });

    test('Service Worker existe', () {
      File? swFile;
      final paths = [
        'arkalia_cia/web/sw.js',
        '../arkalia_cia/web/sw.js',
        '../../arkalia_cia/web/sw.js',
      ];
      
      for (final path in paths) {
        final file = File(path);
        if (file.existsSync()) {
          swFile = file;
          break;
        }
      }
      
      expect(swFile, isNotNull, 
        reason: 'sw.js doit exister dans arkalia_cia/web/');
    });

    test('Icônes PWA existent', () {
      final basePaths = [
        'arkalia_cia/web/icons/',
        '../arkalia_cia/web/icons/',
        '../../arkalia_cia/web/icons/',
      ];
      
      String? basePath;
      for (final path in basePaths) {
        if (File('$path/Icon-192.png').existsSync()) {
          basePath = path;
          break;
        }
      }
      
      expect(basePath, isNotNull, 
        reason: 'Dossier icons/ doit exister dans arkalia_cia/web/');
      
      expect(File('$basePath/Icon-192.png').existsSync(), isTrue, 
        reason: 'Icon-192.png doit exister');
      expect(File('$basePath/Icon-512.png').existsSync(), isTrue, 
        reason: 'Icon-512.png doit exister');
      expect(File('$basePath/Icon-maskable-192.png').existsSync(), isTrue, 
        reason: 'Icon-maskable-192.png doit exister');
      expect(File('$basePath/Icon-maskable-512.png').existsSync(), isTrue, 
        reason: 'Icon-maskable-512.png doit exister');
    });

    test('Favicon existe', () {
      File? faviconFile;
      final paths = [
        'arkalia_cia/web/favicon.png',
        '../arkalia_cia/web/favicon.png',
        '../../arkalia_cia/web/favicon.png',
      ];
      
      for (final path in paths) {
        final file = File(path);
        if (file.existsSync()) {
          faviconFile = file;
          break;
        }
      }
      
      expect(faviconFile, isNotNull, 
        reason: 'favicon.png doit exister dans arkalia_cia/web/');
    });

    test('manifest.json contient les bonnes valeurs', () {
      File? manifestFile;
      final paths = [
        'arkalia_cia/web/manifest.json',
        '../arkalia_cia/web/manifest.json',
        '../../arkalia_cia/web/manifest.json',
      ];
      
      for (final path in paths) {
        final file = File(path);
        if (file.existsSync()) {
          manifestFile = file;
          break;
        }
      }
      
      expect(manifestFile, isNotNull, 
        reason: 'manifest.json doit exister dans arkalia_cia/web/');
      
      final manifestContent = manifestFile!.readAsStringSync();
      final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;

      // Vérifier le nom
      expect(manifest['name'], contains('Arkalia CIA'), 
        reason: 'Le nom doit contenir "Arkalia CIA"');
      
      // Vérifier le thème
      expect(manifest['theme_color'], isNotNull, 
        reason: 'theme_color doit être défini');
      expect(manifest['background_color'], isNotNull, 
        reason: 'background_color doit être défini');
      
      // Vérifier le display mode
      expect(manifest['display'], equals('standalone'), 
        reason: 'display doit être "standalone" pour PWA');
    });
  });
}


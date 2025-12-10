// Tests pour la PWA Arkalia CIA
// Date: 10 décembre 2025

import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  group('PWA Configuration Tests', () {
    test('manifest.json existe et est valide', () {
      final manifestFile = File('arkalia_cia/web/manifest.json');
      expect(manifestFile.existsSync(), isTrue, 
        reason: 'manifest.json doit exister');

      final manifestContent = manifestFile.readAsStringSync();
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
      final indexFile = File('arkalia_cia/web/index.html');
      expect(indexFile.existsSync(), isTrue, 
        reason: 'index.html doit exister');

      final indexContent = indexFile.readAsStringSync();
      
      // Vérifier que manifest.json est référencé
      expect(indexContent.contains('manifest.json'), isTrue, 
        reason: 'index.html doit référencer manifest.json');
      
      // Vérifier que le service worker est enregistré
      expect(indexContent.contains('serviceWorker'), isTrue, 
        reason: 'index.html doit enregistrer le service worker');
    });

    test('Service Worker existe', () {
      final swFile = File('arkalia_cia/web/sw.js');
      expect(swFile.existsSync(), isTrue, 
        reason: 'sw.js doit exister');
    });

    test('Icônes PWA existent', () {
      final icon192 = File('arkalia_cia/web/icons/Icon-192.png');
      final icon512 = File('arkalia_cia/web/icons/Icon-512.png');
      final iconMaskable192 = File('arkalia_cia/web/icons/Icon-maskable-192.png');
      final iconMaskable512 = File('arkalia_cia/web/icons/Icon-maskable-512.png');
      
      expect(icon192.existsSync(), isTrue, 
        reason: 'Icon-192.png doit exister');
      expect(icon512.existsSync(), isTrue, 
        reason: 'Icon-512.png doit exister');
      expect(iconMaskable192.existsSync(), isTrue, 
        reason: 'Icon-maskable-192.png doit exister');
      expect(iconMaskable512.existsSync(), isTrue, 
        reason: 'Icon-maskable-512.png doit exister');
    });

    test('Favicon existe', () {
      final faviconFile = File('arkalia_cia/web/favicon.png');
      expect(faviconFile.existsSync(), isTrue, 
        reason: 'favicon.png doit exister');
    });

    test('manifest.json contient les bonnes valeurs', () {
      final manifestFile = File('arkalia_cia/web/manifest.json');
      final manifestContent = manifestFile.readAsStringSync();
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


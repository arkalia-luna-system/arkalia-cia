import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service de gestion des favoris/épinglages des portails santé
class HealthPortalFavoritesService {
  static const String _favoritesKey = 'health_portal_favorites';

  /// Récupère la liste des URLs des portails favoris
  static Future<Set<String>> getFavoriteUrls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson == null) {
        return <String>{};
      }
      final List<dynamic> favorites = jsonDecode(favoritesJson);
      return favorites.map((url) => url.toString()).toSet();
    } catch (e) {
      return <String>{};
    }
  }

  /// Ajoute un portail aux favoris
  static Future<bool> addFavorite(String url) async {
    try {
      final favorites = await getFavoriteUrls();
      favorites.add(url);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  /// Retire un portail des favoris
  static Future<bool> removeFavorite(String url) async {
    try {
      final favorites = await getFavoriteUrls();
      favorites.remove(url);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un portail est dans les favoris
  static Future<bool> isFavorite(String url) async {
    final favorites = await getFavoriteUrls();
    return favorites.contains(url);
  }

  /// Sauvegarde la liste des favoris
  static Future<bool> _saveFavorites(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(favorites.toList());
      await prefs.setString(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle l'état favori d'un portail
  static Future<bool> toggleFavorite(String url) async {
    final isFav = await isFavorite(url);
    if (isFav) {
      return await removeFavorite(url);
    } else {
      return await addFavorite(url);
    }
  }
}


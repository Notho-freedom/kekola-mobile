// lib/services/api_service.dart
// Service pour communiquer avec l'API backend

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL de base de l'API - Détection automatique selon la plateforme
  // Pour Web : http://localhost:8000
  // Pour Android Emulator : http://10.0.2.2:8000
  // Pour iOS Simulator : http://localhost:8000
  // Pour appareil physique : http://VOTRE_IP_LOCALE:8000
  static String get baseUrl {
    if (kIsWeb) {
      // Mode Web : utiliser localhost
      return 'http://localhost:8000';
    } else {
      // Pour mobile, utiliser 10.0.2.2 pour Android, localhost pour iOS
      // Vous pouvez modifier cette valeur selon votre configuration
      // Pour Android Emulator, décommentez la ligne suivante :
      // return 'http://10.0.2.2:8000';
      // Pour tester sur appareil physique, utilisez votre IP locale :
      // return 'http://192.168.1.XXX:8000';
      return 'http://localhost:8000';
    }
  }
  
  // Clé pour stocker le token dans SharedPreferences
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Récupère le token stocké
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Sauvegarde le token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Sauvegarde le refresh token
  static Future<void> _saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Supprime les tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Récupère les headers avec le token d'authentification (avec rafraîchissement automatique)
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      var token = await _getToken();
      // Si pas de token mais qu'on a un refresh token, essayer de rafraîchir
      if (token == null || token.isEmpty) {
        if (await hasRefreshToken()) {
          try {
            await refreshToken();
            token = await _getToken();
          } catch (e) {
            // Échec du refresh, continuer sans token
          }
        }
      }
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Gère les erreurs HTTP
  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final errorBody = json.decode(response.body);
      final errorMessage = errorBody['detail'] ?? 'Une erreur est survenue';
      throw Exception(errorMessage);
    }
  }

  // ========== AUTHENTIFICATION ==========

  /// Connexion utilisateur
  /// Retourne les tokens (access_token, refresh_token)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      _handleError(response);

      final data = json.decode(response.body);
      
      // Sauvegarde les tokens
      await _saveToken(data['access_token']);
      await _saveRefreshToken(data['refresh_token']);

      return data;
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Inscription utilisateur
  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      _handleError(response);

      final data = json.decode(response.body);
      
      // Sauvegarder les tokens si l'inscription retourne des tokens (connexion automatique)
      if (data['access_token'] != null && data['refresh_token'] != null) {
        await _saveToken(data['access_token']);
        await _saveRefreshToken(data['refresh_token']);
      }

      return data;
    } catch (e) {
      throw Exception('Erreur d\'inscription: ${e.toString()}');
    }
  }

  /// Rafraîchit le token d'accès (persistance agressive)
  static Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken == null) {
        throw Exception('Aucun refresh token disponible');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      // Si le refresh échoue avec 401, le refresh token est expiré
      if (response.statusCode == 401) {
        await clearTokens();
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      _handleError(response);

      final data = json.decode(response.body);
      // Sauvegarder les nouveaux tokens
      await _saveToken(data['access_token']);
      await _saveRefreshToken(data['refresh_token']);
    } catch (e) {
      // Si le refresh échoue, nettoyer les tokens
      await clearTokens();
      rethrow;
    }
  }

  // ========== MÉTRIQUES ==========

  /// Crée une nouvelle métrique (saisie)
  static Future<Map<String, dynamic>> createMetric({
    required String date,
    required double sales,
    required double cash,
    String source = 'APP',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/metrics'),
        headers: await _getHeaders(),
        body: json.encode({
          'date': date,
          'sales': sales,
          'cash': cash,
          'source': source,
        }),
      );

      // Si 401, essayer de rafraîchir le token
      if (response.statusCode == 401) {
        await refreshToken();
        return createMetric(date: date, sales: sales, cash: cash, source: source);
      }

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur lors de la création de la métrique: ${e.toString()}');
    }
  }

  /// Récupère les métriques pour une période
  /// range: "10d" pour 10 jours, "30d" pour 30 jours, etc.
  static Future<List<dynamic>> getMetrics({String range = '10d'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/metrics?range=$range'),
        headers: await _getHeaders(),
      );

      // Si 401, essayer de rafraîchir le token
      if (response.statusCode == 401) {
        await refreshToken();
        return getMetrics(range: range);
      }

      _handleError(response);

      final data = json.decode(response.body);
      return data['metrics'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des métriques: ${e.toString()}');
    }
  }

  /// Récupère les insights pour une date donnée
  /// date: Format ISO "YYYY-MM-DD"
  static Future<Map<String, dynamic>> getInsights(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/insights?date=$date'),
        headers: await _getHeaders(),
      );

      // Si 401, essayer de rafraîchir le token
      if (response.statusCode == 401) {
        await refreshToken();
        return getInsights(date);
      }

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des insights: ${e.toString()}');
    }
  }

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  /// Vérifie si un refresh token existe
  static Future<bool> hasRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  // ========== UTILISATEUR ==========

  /// Récupère le profil de l'utilisateur connecté
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 401) {
        await refreshToken();
        return getCurrentUser();
      }

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: ${e.toString()}');
    }
  }

  /// Met à jour le profil de l'utilisateur
  static Future<Map<String, dynamic>> updateUser({
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (password != null) body['password'] = password;

      final response = await http.put(
        Uri.parse('$baseUrl/user/me'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 401) {
        await refreshToken();
        return updateUser(name: name, email: email, password: password);
      }

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: ${e.toString()}');
    }
  }

  // ========== DASHBOARD ==========

  /// Récupère les statistiques du dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/dashboard'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 401) {
        await refreshToken();
        return getDashboardStats();
      }

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des stats: ${e.toString()}');
    }
  }

  /// Récupère les données pour les graphiques
  static Future<Map<String, dynamic>> getGraphData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/graphs'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 401) {
        await refreshToken();
        return getGraphData();
      }

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des graphiques: ${e.toString()}');
    }
  }

  // ========== NOTIFICATIONS ==========

  /// Récupère les notifications de l'utilisateur
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 401) {
        await refreshToken();
        return getNotifications();
      }

      _handleError(response);
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications: ${e.toString()}');
    }
  }

  /// Marque une notification comme lue
  static Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 401) {
        await refreshToken();
        return markNotificationAsRead(notificationId);
      }

      _handleError(response);
    } catch (e) {
      throw Exception('Erreur lors du marquage de la notification: ${e.toString()}');
    }
  }

  /// Marque toutes les notifications comme lues
  static Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 401) {
        await refreshToken();
        return markAllNotificationsAsRead();
      }

      _handleError(response);
    } catch (e) {
      throw Exception('Erreur lors du marquage des notifications: ${e.toString()}');
    }
  }
}


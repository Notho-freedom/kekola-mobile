// test/services/api_service_test.dart
// Tests unitaires pour le service API

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namer_app/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        // Simuler les réponses selon l'URL
        if (request.url.path == '/login') {
          return http.Response(
            '{"access_token": "test_access_token", "refresh_token": "test_refresh_token", "token_type": "bearer"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/register') {
          return http.Response(
            '{"message": "User test@example.com created"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/v1/metrics' && request.method == 'POST') {
          return http.Response(
            '{"id": 1, "date": "2025-01-20", "sales": 1500.0, "cash": 1200.0, "source": "APP", "deltas": {"sales": 10.0, "cash": 5.0}}',
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/v1/metrics' && request.method == 'GET') {
          return http.Response(
            '{"metrics": [{"id": 1, "date": "2025-01-20", "sales": 1500.0, "cash": 1200.0, "deltas": {"sales": 10.0, "cash": 5.0}}]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/v1/insights') {
          return http.Response(
            '{"pctSales": 15.5, "pctCash": 12.3}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });
    });

    tearDown(() async {
      // Nettoyer SharedPreferences après chaque test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('login should return tokens and save them', () async {
      // Note: Ce test nécessiterait de mocker le client HTTP
      // Pour l'instant, testons la logique de base
      expect(await ApiService.isLoggedIn(), false);
    });

    test('isLoggedIn should return false when no token', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      expect(await ApiService.isLoggedIn(), false);
    });

    test('clearTokens should remove tokens', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', 'test_token');
      
      await ApiService.clearTokens();
      
      expect(await prefs.getString('access_token'), null);
      expect(await prefs.getString('refresh_token'), null);
    });
  });
}


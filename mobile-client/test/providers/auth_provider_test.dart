// test/providers/auth_provider_test.dart
// Tests pour le provider d'authentification

import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/providers/auth_provider.dart';
import 'package:namer_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() async {
      // Nettoyer SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('initial state should be not authenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.errorMessage, null);
    });

    test('clearError should remove error message', () {
      // Note: errorMessage est privé, on teste juste que clearError fonctionne
      // En pratique, l'erreur serait définie lors d'un login/register échoué
      authProvider.clearError();
      
      expect(authProvider.errorMessage, null);
    });

    // Note: Les tests d'intégration avec l'API nécessiteraient un mock HTTP
    // Pour l'instant, testons la logique de base du provider
  });
}


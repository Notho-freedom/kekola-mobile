// lib/providers/auth_provider.dart
// Provider pour gérer l'état d'authentification

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Vérifie si l'utilisateur est déjà connecté au démarrage (persistance agressive)
  Future<void> _checkAuthStatus() async {
    final hasToken = await ApiService.isLoggedIn();
    if (hasToken) {
      // Vérifier que le token est encore valide en essayant de récupérer le profil
      try {
        await ApiService.getCurrentUser();
        _isAuthenticated = true;
      } catch (e) {
        // Token invalide ou expiré, essayer de le rafraîchir automatiquement
        try {
          await ApiService.refreshToken();
          // Réessayer après rafraîchissement
          try {
            await ApiService.getCurrentUser();
            _isAuthenticated = true;
          } catch (e2) {
            // Même après refresh, ça ne marche pas, nettoyer
            await ApiService.clearTokens();
            _isAuthenticated = false;
          }
        } catch (refreshError) {
          // Le refresh a échoué, nettoyer
          await ApiService.clearTokens();
          _isAuthenticated = false;
        }
      }
    } else {
      // Vérifier s'il y a un refresh token même sans access token
      final hasRefreshToken = await ApiService.hasRefreshToken();
      if (hasRefreshToken) {
        try {
          // Essayer de rafraîchir avec le refresh token
          await ApiService.refreshToken();
          await ApiService.getCurrentUser();
          _isAuthenticated = true;
        } catch (e) {
          // Échec, nettoyer
          await ApiService.clearTokens();
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }
    }
    notifyListeners();
  }

  // Méthode publique pour vérifier l'authentification (utilisée par SplashScreen)
  Future<void> checkAuthStatus() async {
    await _checkAuthStatus();
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.login(email, password);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Inscription
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.register(email, password, name);
      // Si l'inscription réussit et retourne des tokens, l'utilisateur est connecté
      _isAuthenticated = await ApiService.isLoggedIn();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await ApiService.clearTokens();
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


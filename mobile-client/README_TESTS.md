# Guide des Tests Flutter

## Exécution des tests

### Tous les tests
```bash
cd mobile-client
flutter test
```

### Tests avec couverture
```bash
flutter test --coverage
```

### Tests spécifiques
```bash
# Tests unitaires du service API
flutter test test/services/api_service_test.dart

# Tests du provider
flutter test test/providers/auth_provider_test.dart

# Tests widget
flutter test test/widgets/
```

### Mode verbose
```bash
flutter test --verbose
```

## Structure des tests

- `test/services/api_service_test.dart` - Tests unitaires pour le service API
- `test/providers/auth_provider_test.dart` - Tests pour le provider d'authentification
- `test/widgets/login_screen_test.dart` - Tests widget pour l'écran de connexion
- `test/widgets/signup_screen_test.dart` - Tests widget pour l'écran d'inscription

## Types de tests

### Tests unitaires
Testent la logique métier isolée (services, providers)

### Tests widget
Testent l'interface utilisateur et les interactions

### Tests d'intégration (à venir)
Testent le flux complet avec un backend mocké

## Notes

- Les tests utilisent `SharedPreferences` pour simuler le stockage
- Pour tester avec un vrai backend, utiliser un serveur de test séparé
- Les mocks HTTP peuvent être ajoutés avec `http` package et `MockClient`


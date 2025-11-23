# ✅ Corrections de la Connexion Frontend-Backend

## 🔧 Problème Résolu

### Erreur : `ERR_CONNECTION_TIMED_OUT` sur `10.0.2.2:8000/register`

**Cause** : L'application Flutter tourne en mode **Web**, mais utilisait l'URL `10.0.2.2:8000` qui est uniquement valable pour l'émulateur Android.

**Solution** : Détection automatique de la plateforme dans `api_service.dart` :
- **Mode Web** : Utilise `http://localhost:8000`
- **Android Emulator** : Peut être configuré pour utiliser `http://10.0.2.2:8000`
- **iOS Simulator** : Utilise `http://localhost:8000`

## ✅ Modifications Effectuées

### 1. Service API (`lib/services/api_service.dart`)
- ✅ Détection automatique de la plateforme avec `kIsWeb`
- ✅ URL adaptée selon la plateforme
- ✅ Configuration facile pour Android Emulator et appareils physiques

### 2. Routes Vérifiées
- ✅ `POST /register` - Fonctionne
- ✅ `POST /login` - Fonctionne
- ✅ `POST /refresh` - Fonctionne
- ✅ `POST /v1/metrics` - Fonctionne
- ✅ `GET /v1/metrics` - Fonctionne
- ✅ `GET /v1/insights` - Fonctionne

### 3. Serveur Backend
- ✅ Écoute sur `0.0.0.0:8000` (accessible depuis tous les réseaux)
- ✅ CORS configuré et actif
- ✅ Base de données SQLite fonctionnelle

## 🚀 Configuration Actuelle

### URL par Plateforme

**Mode Web** (actuel) :
```dart
baseUrl = 'http://localhost:8000'
```

**Android Emulator** (à configurer si nécessaire) :
```dart
// Dans api_service.dart, modifier :
return 'http://10.0.2.2:8000';
```

**Appareil Physique** :
```dart
// Utiliser votre IP locale, ex :
return 'http://192.168.1.XXX:8000';
```

## ✅ Vérification

Le serveur backend est accessible :
- ✅ URL : http://localhost:8000
- ✅ Documentation : http://localhost:8000/docs
- ✅ Routes testées et fonctionnelles

## 📝 Prochaines Étapes

1. ✅ Serveur backend lancé
2. ✅ URL configurée pour le web
3. ⏭️ Tester l'inscription depuis l'app Flutter
4. ⏭️ Tester la connexion depuis l'app Flutter

## 🔍 Dépannage

Si vous avez encore des erreurs de connexion :

1. **Vérifier que le serveur est lancé** :
   ```bash
   cd backend
   .\venv\Scripts\Activate.ps1
   uvicorn run:app --host 0.0.0.0 --port 8000 --reload
   ```

2. **Tester depuis le navigateur** :
   ```
   http://localhost:8000
   ```

3. **Vérifier les logs du serveur** pour voir les requêtes reçues

4. **Vérifier la console du navigateur** pour les erreurs CORS


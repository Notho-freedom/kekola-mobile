# 🔧 Configuration de l'URL API

## 📱 Détection Automatique de la Plateforme

Le service API détecte automatiquement la plateforme et utilise l'URL appropriée :

- **Mode Web** : `http://localhost:8000`
- **Android Emulator** : `http://10.0.2.2:8000` (à configurer manuellement)
- **iOS Simulator** : `http://localhost:8000`
- **Appareil Physique** : `http://VOTRE_IP_LOCALE:8000` (à configurer manuellement)

## 🔧 Configuration Manuelle

Si la détection automatique ne fonctionne pas, modifiez `lib/services/api_service.dart` :

```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else {
    // Pour Android Emulator, décommentez :
    // return 'http://10.0.2.2:8000';
    
    // Pour appareil physique, utilisez votre IP :
    // return 'http://192.168.1.XXX:8000';
    
    return 'http://localhost:8000';
  }
}
```

## 🌐 Trouver votre IP Locale

### Windows
```powershell
ipconfig
# Chercher "IPv4 Address" sous votre carte réseau
```

### Mac/Linux
```bash
ifconfig
# ou
ip addr
```

## ✅ Routes Disponibles

- `POST /register` - Inscription
- `POST /login` - Connexion
- `POST /refresh` - Rafraîchissement token
- `POST /v1/metrics` - Création métrique
- `GET /v1/metrics?range=Xd` - Liste métriques
- `GET /v1/insights?date=YYYY-MM-DD` - Insights

## 🧪 Test de Connexion

Pour tester si le serveur est accessible :

```bash
# Depuis le terminal
curl http://localhost:8000

# Ou dans le navigateur
http://localhost:8000
```

## ⚠️ Problèmes Courants

### ERR_CONNECTION_TIMED_OUT
- Vérifier que le serveur backend est lancé
- Vérifier que le port 8000 n'est pas bloqué par le firewall
- Vérifier l'URL dans `api_service.dart`

### CORS Error
- Le CORS est déjà configuré dans le backend
- Vérifier que le serveur écoute sur `0.0.0.0:8000`

### 10.0.2.2 ne fonctionne pas
- Cette adresse fonctionne uniquement depuis l'émulateur Android
- Pour le web, utiliser `localhost:8000`
- Pour appareil physique, utiliser votre IP locale


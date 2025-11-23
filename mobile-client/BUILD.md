# Guide de Build - Kekola Mobile

Ce guide explique comment générer les artefacts de l'application Flutter pour différentes plateformes.

## 🚀 Détection Automatique de l'URL Backend

L'application détecte automatiquement l'URL du backend selon l'environnement :

- **Production (Release/Profile)** : `https://kekola-mobile.onrender.com`
- **Développement (Debug)** :
  - Web : `http://localhost:8000`
  - Android Emulator : `http://10.0.2.2:8000`
  - iOS Simulator / Appareil physique : `http://localhost:8000`

### Configuration Manuelle

Vous pouvez également définir manuellement l'URL via le code :

```dart
// Définir une URL personnalisée
await ApiService.setBaseUrl('https://votre-serveur.com');

// Réinitialiser à la détection automatique
await ApiService.resetBaseUrl();
```

## 📦 Génération des Artefacts

### Option 1 : Scripts Automatisés

#### Windows
```bash
cd mobile-client
build.bat
```

#### Linux/Mac
```bash
cd mobile-client
chmod +x build.sh
./build.sh
```

### Option 2 : Commandes Flutter Directes

#### Android APK (Release)
```bash
cd mobile-client
flutter clean
flutter pub get
flutter build apk --release
```
**Artefact généré** : `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (AAB) - Pour Google Play
```bash
cd mobile-client
flutter clean
flutter pub get
flutter build appbundle --release
```
**Artefact généré** : `build/app/outputs/bundle/release/app-release.aab`

#### iOS (nécessite Mac)
```bash
cd mobile-client
flutter clean
flutter pub get
flutter build ios --release
```
**Artefact généré** : `build/ios/iphoneos/`

#### Web
```bash
cd mobile-client
flutter clean
flutter pub get
flutter build web --release
```
**Artefact généré** : `build/web/`

## 📱 Installation des Artefacts

### Android APK
1. Transférez le fichier `app-release.apk` sur votre appareil Android
2. Activez "Sources inconnues" dans les paramètres de sécurité
3. Ouvrez le fichier APK et installez l'application

### Android App Bundle (AAB)
- Utilisez Google Play Console pour uploader le fichier `.aab`
- Le fichier AAB est optimisé pour la distribution via Google Play

### Web
1. Déployez le contenu du dossier `build/web/` sur un serveur web
2. L'application sera accessible via un navigateur

### iOS
1. Utilisez Xcode pour signer et déployer l'application
2. Ou utilisez TestFlight pour la distribution

## 🔧 Prérequis

- Flutter SDK installé et configuré
- Variables d'environnement configurées si nécessaire
- Pour Android : Android SDK et outils de build
- Pour iOS : Xcode (sur Mac uniquement)

## 🌐 URL de Production

L'application utilise automatiquement l'URL de production lors des builds Release/Profile :
- **Backend** : https://kekola-mobile.onrender.com

## 📝 Notes

- Les builds Release utilisent automatiquement l'URL de production
- Les builds Debug utilisent l'URL de développement locale
- L'URL peut être personnalisée via `ApiService.setBaseUrl()`


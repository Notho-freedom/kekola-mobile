# Configuration Firebase - Guide de Synchronisation

## 📋 Vue d'ensemble

Le module de synchronisation Firebase permet de sauvegarder automatiquement vos métriques (ventes, cash) vers Firebase Firestore. La synchronisation automatique est **désactivée par défaut** et peut être activée depuis l'écran Paramètres.

## 🔧 Configuration Firebase

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Suivez les étapes pour créer votre projet
4. Notez le nom de votre projet

### 2. Configurer Firebase pour Android

1. Dans Firebase Console, cliquez sur l'icône Android
2. Entrez le nom du package : `com.example.namer_app` (vérifiez dans `android/app/build.gradle`)
3. Téléchargez le fichier `google-services.json`
4. Placez-le dans `android/app/google-services.json`
5. Ajoutez dans `android/build.gradle` :
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```
6. Ajoutez dans `android/app/build.gradle` :
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 3. Configurer Firebase pour iOS

1. Dans Firebase Console, cliquez sur l'icône iOS
2. Entrez le Bundle ID (vérifiez dans `ios/Runner.xcodeproj`)
3. Téléchargez le fichier `GoogleService-Info.plist`
4. Placez-le dans `ios/Runner/GoogleService-Info.plist`
5. Ouvrez `ios/Runner.xcodeproj` dans Xcode
6. Faites glisser `GoogleService-Info.plist` dans le projet

### 4. Configurer Firebase pour Web

1. Dans Firebase Console, cliquez sur l'icône Web
2. Enregistrez votre app
3. Copiez la configuration Firebase
4. Ajoutez les scripts dans `web/index.html` :
```html
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js"></script>
<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

### 5. Activer Firebase dans le code

1. Ouvrez `lib/services/firebase_init.dart`
2. Décommentez la ligne :
```dart
await Firebase.initializeApp();
```
3. Ajoutez l'initialisation dans `lib/main.dart` :
```dart
import 'services/firebase_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.initialize();
  runApp(...);
}
```

## 🔐 Configuration Firestore

### 1. Activer Firestore

1. Dans Firebase Console, allez dans "Firestore Database"
2. Cliquez sur "Créer une base de données"
3. Choisissez "Mode test" pour commencer
4. Sélectionnez une région

### 2. Règles de sécurité (Mode test)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/metrics/{metricId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📱 Utilisation

### Activer la synchronisation automatique

1. Ouvrez l'application
2. Allez dans **Profil** → **Paramètres**
3. Activez le switch **"Synchronisation automatique"**
4. La première fois, Firebase Auth sera initialisé avec votre email
5. Testez la connexion avec le bouton **"Tester la connexion"**

### Structure des données dans Firestore

```
users/
  {userId}/
    metrics/
      {date}/
        - date: "2024-01-15"
        - sales: 1500.0
        - cash: 800.0
        - source: "mobile"
        - syncedAt: Timestamp
        - updatedAt: Timestamp
```

## 🔍 Fonctionnalités

### Synchronisation automatique

- ✅ Synchronise automatiquement chaque nouvelle métrique vers Firebase
- ✅ Fonctionne en arrière-plan
- ✅ Ne bloque pas l'utilisateur en cas d'erreur
- ✅ Peut être activée/désactivée à tout moment

### Test de connexion

- Vérifie que Firebase est correctement configuré
- Teste la connexion à Firestore
- Affiche le statut de connexion

## ⚠️ Notes importantes

1. **Sécurité** : La synchronisation utilise Firebase Auth. Assurez-vous que les règles de sécurité Firestore sont correctement configurées.

2. **Performance** : La synchronisation se fait de manière asynchrone et n'affecte pas les performances de l'application.

3. **Données** : Les métriques sont stockées dans Firestore sous `users/{userId}/metrics/{date}`.

4. **Défaut OFF** : La synchronisation automatique est **désactivée par défaut** pour respecter la vie privée de l'utilisateur.

## 🐛 Dépannage

### Erreur "Firebase not initialized"

- Vérifiez que `Firebase.initializeApp()` est appelé dans `main.dart`
- Vérifiez que les fichiers de configuration sont présents

### Erreur "Permission denied"

- Vérifiez les règles de sécurité Firestore
- Vérifiez que l'utilisateur est authentifié

### Synchronisation ne fonctionne pas

- Vérifiez que le switch est activé dans Paramètres
- Testez la connexion avec le bouton de test
- Vérifiez les logs de la console


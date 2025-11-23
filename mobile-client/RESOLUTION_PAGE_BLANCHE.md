# Résolution : Page Blanche après Déploiement

## 🔍 Diagnostic

Si vous voyez une page blanche après le déploiement, suivez ces étapes :

### 1. Vérifier la Console du Navigateur

**Ouvrez la console (F12)** et vérifiez les erreurs :

- **Erreur 404** : Fichiers manquants
- **Erreur CORS** : Problème de connexion API
- **Erreur JavaScript** : Problème de compilation

### 2. Problèmes Courants et Solutions

#### Problème 1 : Base href incorrect

**Symptôme** : Erreurs 404 sur les fichiers JS/CSS

**Solution** : Vérifiez que le `base href` dans `index.html` correspond à votre chemin de déploiement.

Si votre site est à la racine (`https://votre-domaine.com/`) :
```html
<base href="/">
```

Si votre site est dans un sous-dossier (`https://votre-domaine.com/app/`) :
```html
<base href="/app/">
```

#### Problème 2 : Service Worker

**Symptôme** : Page blanche, pas d'erreurs dans la console

**Solution** : Désactivez ou supprimez le service worker :

1. Ouvrez la console (F12)
2. Allez dans l'onglet **Application** > **Service Workers**
3. Cliquez sur **Unregister** pour désactiver le service worker
4. Rechargez la page (Ctrl+F5)

Ou modifiez `index.html` pour désactiver le service worker :

```html
<script>
  // Désactiver le service worker
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      for(let registration of registrations) {
        registration.unregister();
      }
    });
  }
</script>
```

#### Problème 3 : Fichiers manquants

**Symptôme** : Erreurs 404 dans la console

**Solution** : Vérifiez que TOUS les fichiers sont uploadés :

- `index.html`
- `main.dart.js`
- `flutter.js`
- `flutter_bootstrap.js`
- `flutter_service_worker.js`
- `canvaskit.wasm`
- `canvaskit.js`
- Tous les fichiers dans `icons/`
- Tous les autres fichiers du dossier `build/web/`

#### Problème 4 : Permissions des fichiers

**Symptôme** : Erreurs 403 (Forbidden)

**Solution** : Vérifiez les permissions :
- **Fichiers** : 644
- **Dossiers** : 755

#### Problème 5 : Problème de cache

**Symptôme** : Ancienne version chargée

**Solution** :
1. Videz le cache du navigateur (Ctrl+Shift+Delete)
2. Rechargez en mode hard refresh (Ctrl+F5)
3. Ou ouvrez en navigation privée

## 🛠️ Solutions Rapides

### Solution 1 : Rebuild avec base href personnalisé

Si votre site est dans un sous-dossier :

```bash
cd mobile-client
flutter build web --release --base-href="/votre-sous-dossier/"
```

### Solution 2 : Vérifier index.html

Assurez-vous que `index.html` contient :

```html
<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <title>Kekola Mobile</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

### Solution 3 : Vérifier les chemins dans manifest.json

Vérifiez que `manifest.json` utilise des chemins relatifs :

```json
{
  "name": "Kekola Mobile",
  "short_name": "Kekola",
  "start_url": "/",
  "display": "standalone",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    }
  ]
}
```

## 🔧 Script de Vérification

Créez un fichier `test.html` dans `public_html` pour tester :

```html
<!DOCTYPE html>
<html>
<head>
  <title>Test</title>
</head>
<body>
  <h1>Test de connexion</h1>
  <p>Si vous voyez ce message, le serveur fonctionne.</p>
  <script>
    console.log('Test JavaScript OK');
  </script>
</body>
</html>
```

Si `test.html` fonctionne mais pas l'app Flutter, le problème vient de la configuration Flutter.

## 📋 Checklist de Débogage

- [ ] Console du navigateur ouverte (F12)
- [ ] Aucune erreur 404 dans la console
- [ ] Aucune erreur JavaScript dans la console
- [ ] Service worker désactivé (si problème)
- [ ] Cache du navigateur vidé
- [ ] Tous les fichiers uploadés
- [ ] Permissions correctes (644/755)
- [ ] Base href correct dans index.html
- [ ] Test avec test.html réussi

## 🆘 Si Rien ne Fonctionne

1. **Vérifiez les logs serveur** dans cPanel
2. **Testez avec un autre navigateur**
3. **Vérifiez la version de Flutter** : `flutter --version`
4. **Rebuild complet** :
   ```bash
   cd mobile-client
   flutter clean
   flutter pub get
   flutter build web --release
   ```
5. **Contactez le support PlanetHoster** avec les erreurs de la console



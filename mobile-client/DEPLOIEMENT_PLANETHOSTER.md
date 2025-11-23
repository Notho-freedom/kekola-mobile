# Guide de Déploiement sur PlanetHoster

Ce guide explique comment déployer l'application web Flutter sur PlanetHoster.

## 📋 Prérequis

- Compte PlanetHoster actif
- Accès FTP/SFTP ou cPanel
- Build web Flutter généré (`build/web/`)

## 🚀 Méthode 1 : Déploiement via FTP/SFTP

### Étape 1 : Préparer le build

Le build web est déjà généré dans `mobile-client/build/web/`

### Étape 2 : Obtenir les identifiants FTP

1. Connectez-vous à votre espace client PlanetHoster
2. Allez dans **Gestionnaire de fichiers** ou **FTP**
3. Notez les informations suivantes :
   - **Serveur FTP** : `ftp.votre-domaine.com` ou l'adresse fournie
   - **Nom d'utilisateur** : Votre identifiant FTP
   - **Mot de passe** : Votre mot de passe FTP
   - **Port** : 21 (FTP) ou 22 (SFTP)

### Étape 3 : Se connecter via FTP

#### Option A : Utiliser FileZilla (recommandé)

1. Téléchargez et installez [FileZilla](https://filezilla-project.org/)
2. Ouvrez FileZilla
3. Entrez vos identifiants :
   - **Hôte** : `ftp.votre-domaine.com`
   - **Nom d'utilisateur** : Votre identifiant
   - **Mot de passe** : Votre mot de passe
   - **Port** : 21
4. Cliquez sur **Connexion rapide**

#### Option B : Utiliser WinSCP (Windows)

1. Téléchargez [WinSCP](https://winscp.net/)
2. Créez une nouvelle session avec vos identifiants
3. Connectez-vous

### Étape 4 : Uploader les fichiers

1. Naviguez vers le dossier `public_html` ou `www` sur le serveur
2. **Supprimez** tous les fichiers existants (si nécessaire)
3. **Uploadez** tous les fichiers du dossier `build/web/` :
   - Sélectionnez tous les fichiers dans `build/web/`
   - Glissez-déposez ou utilisez le bouton "Uploader"
   - **Important** : Uploadez aussi les dossiers (`icons/`, etc.)

### Étape 5 : Vérifier les permissions

Assurez-vous que les fichiers ont les bonnes permissions :
- **Fichiers** : 644
- **Dossiers** : 755

## 🌐 Méthode 2 : Déploiement via cPanel

### Étape 1 : Accéder au Gestionnaire de fichiers

1. Connectez-vous à cPanel
2. Cliquez sur **Gestionnaire de fichiers**

### Étape 2 : Naviguer vers public_html

1. Allez dans le dossier `public_html`
2. Supprimez les fichiers existants si nécessaire

### Étape 3 : Uploader les fichiers

1. Cliquez sur **Uploader**
2. Sélectionnez tous les fichiers du dossier `build/web/`
3. Attendez la fin de l'upload
4. **Important** : Uploadez aussi les dossiers (`icons/`, etc.)

## ⚙️ Configuration supplémentaire

### Fichier .htaccess (pour Apache)

Créez un fichier `.htaccess` dans `public_html` avec ce contenu :

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>

# Compression GZIP
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# Cache des fichiers statiques
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/ico "access plus 1 year"
  ExpiresByType image/icon "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
  ExpiresByType application/json "access plus 0 seconds"
  ExpiresByType text/html "access plus 0 seconds"
</IfModule>
```

### Configuration pour les routes Flutter

L'application Flutter utilise des routes côté client. Le fichier `.htaccess` ci-dessus gère déjà la redirection vers `index.html` pour toutes les routes.

## 🔍 Vérification après déploiement

1. **Ouvrez votre site** : `https://votre-domaine.com`
2. **Vérifiez la console du navigateur** (F12) :
   - Aucune erreur 404
   - Les fichiers se chargent correctement
3. **Testez la connexion API** :
   - L'application doit se connecter à `https://kekola-mobile.onrender.com`
   - Testez la connexion et l'inscription

## 🐛 Résolution de problèmes

### Erreur 404 sur les routes

**Problème** : Les routes Flutter ne fonctionnent pas (ex: `/dashboard`)

**Solution** : Vérifiez que le fichier `.htaccess` est présent et correctement configuré

### Fichiers manquants

**Problème** : Certains assets ne se chargent pas

**Solution** : 
- Vérifiez que tous les fichiers du dossier `build/web/` ont été uploadés
- Vérifiez les permissions des fichiers (644 pour les fichiers, 755 pour les dossiers)

### Erreur CORS

**Problème** : Erreurs CORS lors de la connexion à l'API

**Solution** : Le backend sur Render est déjà configuré pour accepter toutes les origines. Si le problème persiste, vérifiez la configuration CORS du backend.

### L'application ne se charge pas

**Problème** : Page blanche ou erreur de chargement

**Solution** :
1. Vérifiez la console du navigateur (F12)
2. Vérifiez que `main.dart.js` est bien présent
3. Vérifiez que le serveur supporte les fichiers `.wasm` (CanvasKit)

## 📝 Checklist de déploiement

- [ ] Build web généré (`flutter build web --release`)
- [ ] Identifiants FTP/SFTP obtenus
- [ ] Connexion FTP établie
- [ ] Fichiers uploadés dans `public_html`
- [ ] Fichier `.htaccess` créé (si Apache)
- [ ] Permissions des fichiers vérifiées
- [ ] Site testé dans le navigateur
- [ ] Connexion API testée
- [ ] Routes Flutter testées

## 🔗 URLs importantes

- **Backend API** : `https://kekola-mobile.onrender.com`
- **Votre site** : `https://votre-domaine.com`

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez les logs d'erreur dans cPanel
2. Contactez le support PlanetHoster
3. Vérifiez la documentation PlanetHoster : https://www.planethoster.com/fr/Support


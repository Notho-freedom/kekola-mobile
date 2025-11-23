#!/bin/bash
# Script de déploiement automatique sur PlanetHoster via FTP/SFTP
# Nécessite lftp ou sftp

set -e

echo "=== DEPLOIEMENT SUR PLANETHOSTER ==="
echo ""

# Vérifier que le build existe
if [ ! -f "build/web/index.html" ]; then
    echo "❌ Build web non trouvé!"
    echo "Veuillez d'abord exécuter: flutter build web --release"
    exit 1
fi

echo "✅ Build web trouvé"
echo ""

# Demander les informations FTP
read -p "Serveur FTP (ex: ftp.votre-domaine.com): " FTP_HOST
read -p "Nom d'utilisateur FTP: " FTP_USER
read -s -p "Mot de passe FTP: " FTP_PASS
echo ""
read -p "Chemin sur le serveur (ex: /public_html ou /www): " FTP_PATH

echo ""
echo "📤 Préparation de l'upload..."
echo ""

# Créer le fichier .htaccess si nécessaire
if [ ! -f "build/web/.htaccess" ]; then
    echo "Création du fichier .htaccess..."
    cat > "build/web/.htaccess" << 'EOF'
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
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
  ExpiresByType text/html "access plus 0 seconds"
</IfModule>
EOF
    echo "✅ Fichier .htaccess créé"
fi

# Vérifier si lftp est installé
if command -v lftp &> /dev/null; then
    echo ""
    echo "🚀 Upload via lftp..."
    cd build/web
    lftp -c "
    set ftp:ssl-allow no
    open -u $FTP_USER,$FTP_PASS $FTP_HOST
    cd $FTP_PATH
    mirror --reverse --delete --verbose .
    quit
    "
    echo "✅ Upload terminé!"
elif command -v sftp &> /dev/null; then
    echo ""
    echo "⚠️  lftp non trouvé, utilisation de sftp (manuel)"
    echo ""
    echo "Pour uploader manuellement:"
    echo "1. Utilisez FileZilla ou WinSCP"
    echo "2. Connectez-vous avec:"
    echo "   - Serveur: $FTP_HOST"
    echo "   - Utilisateur: $FTP_USER"
    echo "   - Mot de passe: [votre mot de passe]"
    echo "3. Naviguez vers: $FTP_PATH"
    echo "4. Uploadez TOUS les fichiers de: build/web/"
else
    echo ""
    echo "⚠️  Aucun client FTP trouvé"
    echo ""
    echo "Pour uploader manuellement:"
    echo "1. Utilisez FileZilla ou WinSCP"
    echo "2. Connectez-vous avec:"
    echo "   - Serveur: $FTP_HOST"
    echo "   - Utilisateur: $FTP_USER"
    echo "   - Mot de passe: [votre mot de passe]"
    echo "3. Naviguez vers: $FTP_PATH"
    echo "4. Uploadez TOUS les fichiers de: build/web/"
fi

echo ""
echo "📁 Fichiers à uploader:"
ls -lh build/web/ | wc -l
echo "fichiers trouvés"
echo ""


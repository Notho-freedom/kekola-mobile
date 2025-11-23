@echo off
REM Script de déploiement automatique sur PlanetHoster via FTP
REM Nécessite WinSCP ou FileZilla CLI

echo === DEPLOIEMENT SUR PLANETHOSTER ===
echo.

REM Vérifier que le build existe
if not exist "build\web\index.html" (
    echo ❌ Build web non trouvé!
    echo Veuillez d'abord exécuter: flutter build web --release
    pause
    exit /b 1
)

echo ✅ Build web trouvé
echo.


REM Créer le fichier .htaccess si nécessaire
if not exist "build\web\.htaccess" (
    echo Création du fichier .htaccess...
    (
        echo ^<IfModule mod_rewrite.c^>
        echo   RewriteEngine On
        echo   RewriteBase /
        echo   RewriteRule ^index\.html$ - [L]
        echo   RewriteCond %%{REQUEST_FILENAME} !-f
        echo   RewriteCond %%{REQUEST_FILENAME} !-d
        echo   RewriteRule . /index.html [L]
        echo ^</IfModule^>
        echo.
        echo # Compression GZIP
        echo ^<IfModule mod_deflate.c^>
        echo   AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
        echo ^</IfModule^>
        echo.
        echo # Cache des fichiers statiques
        echo ^<IfModule mod_expires.c^>
        echo   ExpiresActive On
        echo   ExpiresByType image/png "access plus 1 year"
        echo   ExpiresByType text/css "access plus 1 month"
        echo   ExpiresByType application/javascript "access plus 1 month"
        echo   ExpiresByType text/html "access plus 0 seconds"
        echo ^</IfModule^>
    ) > "build\web\.htaccess"
    echo ✅ Fichier .htaccess créé
)

echo.
echo ⚠️  IMPORTANT: Ce script nécessite WinSCP ou FileZilla CLI
echo.
echo Pour uploader manuellement:
echo 1. Ouvrez FileZilla ou WinSCP
echo 2. Connectez-vous avec:
echo    - Serveur: %FTP_HOST%
echo    - Utilisateur: %FTP_USER%
echo    - Mot de passe: %FTP_PASS%
echo 3. Naviguez vers: %FTP_PATH%
echo 4. Uploadez TOUS les fichiers de: build\web\
echo.
echo 📁 Fichiers à uploader:
dir /b "build\web\*.*" | find /c /v ""
echo fichiers trouvés
echo.

pause


@echo off
REM Script de build pour générer les artefacts de l'application Flutter (Windows)

echo === BUILD KEKOLA MOBILE ===
echo.

REM Vérifier que Flutter est installé
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord.
    exit /b 1
)

echo 📦 Vérification des dépendances...
call flutter pub get

echo.
echo 🔨 Nettoyage des builds précédents...
call flutter clean

echo.
echo 📱 Sélectionnez la plateforme à builder:
echo 1) Android APK (Release)
echo 2) Android App Bundle (AAB)
echo 3) Web
echo 4) Tous (Android APK + Web)
echo.
set /p choice="Votre choix (1-4): "

if "%choice%"=="1" (
    echo 🔨 Build Android APK (Release)...
    call flutter build apk --release
    echo ✅ APK généré: build\app\outputs\flutter-apk\app-release.apk
) else if "%choice%"=="2" (
    echo 🔨 Build Android App Bundle (Release)...
    call flutter build appbundle --release
    echo ✅ AAB généré: build\app\outputs\bundle\release\app-release.aab
) else if "%choice%"=="3" (
    echo 🔨 Build Web (Release)...
    call flutter build web --release
    echo ✅ Web build généré: build\web\
) else if "%choice%"=="4" (
    echo 🔨 Build Android APK (Release)...
    call flutter build apk --release
    echo ✅ APK généré
    echo.
    echo 🔨 Build Web (Release)...
    call flutter build web --release
    echo ✅ Web build généré
) else (
    echo ❌ Choix invalide
    exit /b 1
)

echo.
echo ✅ Build terminé avec succès!
echo.
echo 📝 Artefacts générés:
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo   - Android APK: build\app\outputs\flutter-apk\app-release.apk
)
if exist "build\app\outputs\bundle\release" (
    echo   - Android AAB: build\app\outputs\bundle\release\app-release.aab
)
if exist "build\web" (
    echo   - Web: build\web\
)


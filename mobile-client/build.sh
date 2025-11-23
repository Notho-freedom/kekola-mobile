#!/bin/bash
# Script de build pour générer les artefacts de l'application Flutter

set -e

echo "=== BUILD KEKOLA MOBILE ==="
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

echo -e "${BLUE}📦 Vérification des dépendances...${NC}"
flutter pub get

echo ""
echo -e "${BLUE}🔨 Nettoyage des builds précédents...${NC}"
flutter clean

echo ""
echo -e "${BLUE}📱 Sélectionnez la plateforme à builder:${NC}"
echo "1) Android APK (Release)"
echo "2) Android App Bundle (AAB)"
echo "3) iOS (nécessite Mac)"
echo "4) Web"
echo "5) Tous (Android APK + Web)"
echo ""
read -p "Votre choix (1-5): " choice

case $choice in
    1)
        echo -e "${GREEN}🔨 Build Android APK (Release)...${NC}"
        flutter build apk --release
        echo -e "${GREEN}✅ APK généré: build/app/outputs/flutter-apk/app-release.apk${NC}"
        ;;
    2)
        echo -e "${GREEN}🔨 Build Android App Bundle (Release)...${NC}"
        flutter build appbundle --release
        echo -e "${GREEN}✅ AAB généré: build/app/outputs/bundle/release/app-release.aab${NC}"
        ;;
    3)
        echo -e "${GREEN}🔨 Build iOS (Release)...${NC}"
        flutter build ios --release
        echo -e "${GREEN}✅ iOS build terminé${NC}"
        ;;
    4)
        echo -e "${GREEN}🔨 Build Web (Release)...${NC}"
        flutter build web --release
        echo -e "${GREEN}✅ Web build généré: build/web/${NC}"
        ;;
    5)
        echo -e "${GREEN}🔨 Build Android APK (Release)...${NC}"
        flutter build apk --release
        echo -e "${GREEN}✅ APK généré${NC}"
        echo ""
        echo -e "${GREEN}🔨 Build Web (Release)...${NC}"
        flutter build web --release
        echo -e "${GREEN}✅ Web build généré${NC}"
        ;;
    *)
        echo "❌ Choix invalide"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Build terminé avec succès!${NC}"
echo ""
echo -e "${YELLOW}📝 Artefacts générés:${NC}"
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "  - Android APK: build/app/outputs/flutter-apk/app-release.apk"
fi
if [ -d "build/app/outputs/bundle/release" ]; then
    echo "  - Android AAB: build/app/outputs/bundle/release/app-release.aab"
fi
if [ -d "build/web" ]; then
    echo "  - Web: build/web/"
fi
if [ -d "build/ios/iphoneos" ]; then
    echo "  - iOS: build/ios/iphoneos/"
fi


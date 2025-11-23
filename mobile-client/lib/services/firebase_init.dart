// lib/services/firebase_init.dart
// Initialisation de Firebase

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseInit {
  static bool _initialized = false;
  static bool _hasError = false;

  // Initialiser Firebase (optionnel - seulement si configuré)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Note: Pour utiliser Firebase, vous devez :
      // 1. Créer un projet Firebase sur https://console.firebase.google.com
      // 2. Ajouter les fichiers de configuration :
      //    - android/app/google-services.json (Android)
      //    - ios/Runner/GoogleService-Info.plist (iOS)
      //    - web/index.html avec les scripts Firebase (Web)
      // 3. Décommenter la ligne ci-dessous une fois configuré
      
      // Décommentez cette ligne une fois Firebase configuré :
      // await Firebase.initializeApp();
      
      // Pour l'instant, on simule l'initialisation
      // L'application fonctionnera sans Firebase
      if (kDebugMode) {
        print('Firebase non initialisé - mode dégradé (synchronisation désactivée)');
        print('Pour activer Firebase, configurez-le et décommentez Firebase.initializeApp()');
      }
      _initialized = true;
      _hasError = false;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation Firebase: $e');
        print('La synchronisation Firebase sera désactivée');
      }
      _initialized = false;
      _hasError = true;
    }
  }

  static bool get isInitialized => _initialized && !_hasError;
  static bool get hasError => _hasError;
}


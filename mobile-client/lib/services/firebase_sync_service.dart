// lib/services/firebase_sync_service.dart
// Service de synchronisation des données vers Firebase

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Import Firebase - gérer les erreurs si non configuré
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseSyncService {
  static const String _autoSyncKey = 'firebase_auto_sync_enabled';
  static const String _firebaseUserIdKey = 'firebase_user_id';
  
  // Firebase instances
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _initialized = false;
  
  FirebaseSyncService() {
    _initialize();
  }
  
  void _initialize() {
    try {
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _initialized = true;
    } catch (e) {
      // Firebase non configuré - mode dégradé
      _firestore = null;
      _auth = null;
      _initialized = false;
      print('Firebase non initialisé: $e');
    }
  }
  
  // Vérifier si Firebase est disponible
  bool get isFirebaseAvailable => _initialized && _firestore != null && _auth != null;
  
  // Vérifier si la synchronisation automatique est activée
  static Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSyncKey) ?? false; // Par défaut OFF
  }
  
  // Activer/désactiver la synchronisation automatique
  static Future<void> setAutoSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncKey, enabled);
  }
  
  // Obtenir l'ID utilisateur Firebase
  static Future<String?> getFirebaseUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firebaseUserIdKey);
  }
  
  // Enregistrer l'ID utilisateur Firebase
  static Future<void> setFirebaseUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firebaseUserIdKey, userId);
  }
  
  // Initialiser Firebase Auth avec l'email de l'utilisateur
  Future<bool> initializeFirebaseAuth(String email) async {
    if (!isFirebaseAvailable || _auth == null) {
      print('Firebase non disponible - impossible d\'initialiser');
      return false;
    }
    
    try {
      // Essayer de créer un nouvel utilisateur
      // Si l'utilisateur existe déjà, on capturera l'erreur
      final tempPassword = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      
      try {
        final userCredential = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: tempPassword,
        );
        await setFirebaseUserId(userCredential.user?.uid ?? '');
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // L'utilisateur existe déjà - on ne peut pas se connecter sans mot de passe
          print('Utilisateur Firebase existant. Connexion nécessite un mot de passe.');
          return false;
        } else {
          // Autre erreur
          print('Erreur lors de la création de l\'utilisateur Firebase: ${e.code}');
          return false;
        }
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation Firebase Auth: $e');
      return false;
    }
  }
  
  // Alternative: Initialiser avec un token d'authentification personnalisé
  Future<bool> initializeWithCustomToken(String token) async {
    if (!isFirebaseAvailable || _auth == null) {
      return false;
    }
    
    try {
      final userCredential = await _auth!.signInWithCustomToken(token);
      await setFirebaseUserId(userCredential.user?.uid ?? '');
      return true;
    } catch (e) {
      print('Erreur lors de l\'initialisation avec token: $e');
      return false;
    }
  }
  
  // Synchroniser une métrique vers Firebase
  Future<bool> syncMetric({
    required String date,
    required double sales,
    required double cash,
    required String source,
  }) async {
    try {
      // Vérifier si Firebase est disponible
      if (!isFirebaseAvailable || _firestore == null) {
        print('Firebase non disponible - synchronisation ignorée');
        return false;
      }
      
      // Vérifier si la synchronisation automatique est activée
      final autoSyncEnabled = await isAutoSyncEnabled();
      if (!autoSyncEnabled) {
        print('Synchronisation automatique désactivée');
        return false;
      }
      
      // Vérifier si l'utilisateur est authentifié
      final userId = await getFirebaseUserId();
      if (userId == null || userId.isEmpty) {
        print('Utilisateur Firebase non initialisé');
        return false;
      }
      
      // Synchroniser la métrique
      await _firestore!.collection('users').doc(userId).collection('metrics').doc(date).set({
        'date': date,
        'sales': sales,
        'cash': cash,
        'source': source,
        'syncedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Métrique synchronisée vers Firebase: $date');
      return true;
    } catch (e) {
      print('Erreur lors de la synchronisation vers Firebase: $e');
      return false;
    }
  }
  
  // Synchroniser toutes les métriques en attente
  Future<int> syncAllPendingMetrics(List<Map<String, dynamic>> metrics) async {
    int syncedCount = 0;
    
    for (var metric in metrics) {
      final success = await syncMetric(
        date: metric['date'] ?? '',
        sales: (metric['sales'] ?? 0.0).toDouble(),
        cash: (metric['cash'] ?? 0.0).toDouble(),
        source: metric['source'] ?? 'mobile',
      );
      
      if (success) {
        syncedCount++;
      }
    }
    
    return syncedCount;
  }
  
  // Récupérer les métriques depuis Firebase
  Future<List<Map<String, dynamic>>> getMetricsFromFirebase() async {
    if (!isFirebaseAvailable || _firestore == null) {
      return [];
    }
    
    try {
      final userId = await getFirebaseUserId();
      if (userId == null || userId.isEmpty) {
        return [];
      }
      
      final snapshot = await _firestore!
          .collection('users')
          .doc(userId)
          .collection('metrics')
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'date': data['date'] ?? '',
          'sales': data['sales'] ?? 0.0,
          'cash': data['cash'] ?? 0.0,
          'source': data['source'] ?? 'firebase',
          'syncedAt': data['syncedAt']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération depuis Firebase: $e');
      return [];
    }
  }
  
  // Déconnecter Firebase Auth
  Future<void> signOut() async {
    if (!isFirebaseAvailable || _auth == null) {
      return;
    }
    
    try {
      await _auth!.signOut();
      await setFirebaseUserId('');
    } catch (e) {
      print('Erreur lors de la déconnexion Firebase: $e');
    }
  }
  
  // Vérifier la connexion Firebase
  Future<bool> checkConnection() async {
    if (!isFirebaseAvailable || _firestore == null) {
      return false;
    }
    
    try {
      final userId = await getFirebaseUserId();
      if (userId == null || userId.isEmpty) {
        return false;
      }
      
      // Tester la connexion en lisant un document
      await _firestore!.collection('users').doc(userId).get();
      return true;
    } catch (e) {
      print('Erreur de connexion Firebase: $e');
      return false;
    }
  }
}

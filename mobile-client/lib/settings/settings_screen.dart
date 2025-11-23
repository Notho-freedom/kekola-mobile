// lib/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../app/theme/app_theme.dart';
import '../widgets/glassmorphism_card.dart';
import '../services/firebase_sync_service.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = false;
  bool _isLoading = true;
  bool _isSyncing = false;
  String _syncStatus = '';
  String? _firebaseUserId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final autoSync = await FirebaseSyncService.isAutoSyncEnabled();
      final userId = await FirebaseSyncService.getFirebaseUserId();
      final userProfile = await ApiService.getCurrentUser();
      
      setState(() {
        _autoSyncEnabled = autoSync;
        _firebaseUserId = userId;
        _isLoading = false;
        _syncStatus = autoSync ? 'Activée' : 'Désactivée';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _syncStatus = 'Erreur: ${e.toString()}';
      });
    }
  }

  Future<void> _toggleAutoSync(bool value) async {
    setState(() {
      _isSyncing = true;
    });

    try {
      if (value) {
        // Activer la synchronisation - initialiser Firebase Auth si nécessaire
        final userProfile = await ApiService.getCurrentUser();
        final email = userProfile['email'] ?? '';
        
        if (email.isEmpty) {
          throw Exception('Email utilisateur non disponible');
        }

        // Pour l'initialisation, on utilise le même email
        // Note: En production, vous devriez demander le mot de passe ou utiliser un token
        final syncService = FirebaseSyncService();
        final initialized = await syncService.initializeFirebaseAuth(email);

        if (!initialized) {
          throw Exception('Impossible d\'initialiser Firebase Auth');
        }

        await FirebaseSyncService.setAutoSyncEnabled(true);
        final userId = await FirebaseSyncService.getFirebaseUserId();
        
        setState(() {
          _autoSyncEnabled = true;
          _firebaseUserId = userId;
          _syncStatus = 'Activée';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Synchronisation automatique activée'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        // Désactiver la synchronisation
        await FirebaseSyncService.setAutoSyncEnabled(false);
        
        setState(() {
          _autoSyncEnabled = false;
          _syncStatus = 'Désactivée';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Synchronisation automatique désactivée'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      setState(() {
        _autoSyncEnabled = !value; // Revenir à l'état précédent
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _testSync() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Test en cours...';
    });

    try {
      final syncService = FirebaseSyncService();
      final isConnected = await syncService.checkConnection();
      
      setState(() {
        _syncStatus = isConnected ? 'Connexion OK' : 'Connexion échouée';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_syncStatus),
            backgroundColor: isConnected ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Paramètres',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE0E7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        'Configuration',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gérez vos préférences et la synchronisation',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Section Synchronisation Firebase
                      GlassmorphismCard(
                        padding: const EdgeInsets.all(20),
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_sync,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Synchronisation Firebase',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _syncStatus,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: _autoSyncEnabled
                                                  ? AppTheme.successColor
                                                  : AppTheme.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Switch de synchronisation automatique
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                                          'Synchronisation automatique',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Synchroniser automatiquement vos données vers Firebase',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Switch(
                                    value: _autoSyncEnabled,
                                    onChanged: _isSyncing ? null : _toggleAutoSync,
                                    activeColor: AppTheme.successColor,
                                  ),
                                ],
                              ),
                            ),
                            
                            if (_firebaseUserId != null && _firebaseUserId!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.infoColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.infoColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppTheme.infoColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'ID Firebase: ${_firebaseUserId!.substring(0, 8)}...',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.infoColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 16),
                            
                            // Bouton de test
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isSyncing ? null : _testSync,
                                icon: _isSyncing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.refresh),
                                label: Text(_isSyncing ? 'Test en cours...' : 'Tester la connexion'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  side: const BorderSide(color: AppTheme.primaryColor),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Section Notifications
                      GlassmorphismCard(
                        padding: const EdgeInsets.all(20),
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.notifications,
                                    color: AppTheme.warningColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Notifications',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Notifications ${value ? 'activées' : 'désactivées'}',
                      ),
                                    backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                title: Text(
                                'Activer les notifications',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                              activeColor: AppTheme.successColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

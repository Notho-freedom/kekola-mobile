// lib/features/saisie/recap_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../app/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/firebase_sync_service.dart';
import '../../widgets/animated_gradient_button.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../widgets/animated_kpi_card.dart';

class RecapScreen extends StatefulWidget {
  final double sales;
  final double cash;

  const RecapScreen({super.key, required this.sales, required this.cash});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _deltas;

  @override
  void initState() {
    super.initState();
    // Les deltas seront calculés par le backend lors de la sauvegarde
    _deltas = {'sales': 0.0, 'cash': 0.0};
  }

  // Sauvegarde la métrique via l'API
  Future<void> _confirmAndSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Format de date ISO (YYYY-MM-DD)
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Créer la métrique via l'API
      final result = await ApiService.createMetric(
        date: dateStr,
        sales: widget.sales,
        cash: widget.cash,
      );

      // Récupérer les deltas depuis la réponse
      if (result['deltas'] != null) {
        setState(() {
          _deltas = Map<String, dynamic>.from(result['deltas']);
        });
      }

      // Synchroniser vers Firebase si la synchronisation automatique est activée
      final syncService = FirebaseSyncService();
      final autoSyncEnabled = await FirebaseSyncService.isAutoSyncEnabled();
      
      if (autoSyncEnabled) {
        try {
          final synced = await syncService.syncMetric(
            date: dateStr,
            sales: widget.sales,
            cash: widget.cash,
            source: 'mobile',
          );
          
          if (synced && mounted) {
            // La synchronisation a réussi, on peut afficher un message optionnel
            print('Données synchronisées vers Firebase avec succès');
          }
        } catch (e) {
          // Erreur de synchronisation Firebase - ne pas bloquer l'utilisateur
          print('Erreur lors de la synchronisation Firebase: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              autoSyncEnabled 
                ? 'Données enregistrées et synchronisées avec succès !'
                : 'Données enregistrées avec succès !',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Retourner au dashboard
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser les deltas de l'API si disponibles, sinon 0
    final salesVariation = _deltas?['sales']?.toDouble() ?? 0.0;
    final cashVariation = _deltas?['cash']?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Récapitulatif',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header moderne
                GlassmorphismCard(
                  padding: const EdgeInsets.all(24),
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Récapitulatif',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vérifiez vos données avant de confirmer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Cartes de données modernisées
                Row(
                  children: [
                    Expanded(
                      child: AnimatedKpiCard(
                        title: 'Ventes',
                        value: '€${widget.sales.toStringAsFixed(2)}',
                        icon: Icons.trending_up_rounded,
                        gradient: AppTheme.successGradient,
                        iconColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedKpiCard(
                        title: 'Cash',
                        value: '€${widget.cash.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_rounded,
                        gradient: AppTheme.accentGradient,
                        iconColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                if (salesVariation != 0.0 || cashVariation != 0.0) ...[
                  const SizedBox(height: 24),
                  GlassmorphismCard(
                    padding: const EdgeInsets.all(20),
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Variations',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVariationCard(
                                context,
                                label: 'Ventes',
                                variation: salesVariation,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildVariationCard(
                                context,
                                label: 'Cash',
                                variation: cashVariation,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Boutons d'action modernisés
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AnimatedGradientButton(
                        text: 'Confirmer',
                        icon: Icons.check_circle_rounded,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _confirmAndSave,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour afficher une carte de variation
  Widget _buildVariationCard(
    BuildContext context, {
    required String label,
    required double variation,
  }) {
    final isPositive = variation >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isPositive ? AppTheme.successColor : AppTheme.errorColor)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isPositive ? AppTheme.successColor : AppTheme.errorColor)
              .withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isPositive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
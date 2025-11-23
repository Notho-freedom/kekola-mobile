// lib/features/saisie/recap_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../services/api_service.dart';

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données enregistrées avec succès !'),
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
      appBar: CustomAppBar(
        title: 'Récapitulatif',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Récapitulatif de la saisie',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez vos données avant de confirmer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              // Carte Ventes
              _buildDataCard(
                context,
                title: 'Ventes',
                amount: '€${widget.sales.toStringAsFixed(2)}',
                variation: salesVariation,
                icon: Icons.trending_up,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 16),
              // Carte Cash
              _buildDataCard(
                context,
                title: 'Cash',
                amount: '€${widget.cash.toStringAsFixed(2)}',
                variation: cashVariation,
                icon: Icons.account_balance_wallet,
                color: AppTheme.accentColor,
              ),
              const SizedBox(height: 24),
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Retour à SaisieScreen pour modifier
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmAndSave,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Confirmer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour afficher une carte de données
  Widget _buildDataCard(
    BuildContext context, {
    required String title,
    required String amount,
    required double variation,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  variation >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: variation >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${variation.abs().toStringAsFixed(1)}% par rapport à hier',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: variation >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
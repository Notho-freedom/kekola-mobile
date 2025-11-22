// lib/features/saisie/recap_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class RecapScreen extends StatelessWidget {
  final double sales;
  final double cash;

  const RecapScreen({super.key, required this.sales, required this.cash});

  @override
  Widget build(BuildContext context) {
    // Données simulées pour les variations
    const double previousSales = 1200.00; // Ventes de la veille
    const double previousCash = 950.00; // Cash de la veille
    final double salesVariation = ((sales - previousSales) / previousSales * 100);
    final double cashVariation = ((cash - previousCash) / previousCash * 100);

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
                amount: '€${sales.toStringAsFixed(2)}',
                variation: salesVariation,
                icon: Icons.trending_up,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 16),
              // Carte Cash
              _buildDataCard(
                context,
                title: 'Cash',
                amount: '€${cash.toStringAsFixed(2)}',
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
                      onPressed: () {
                        // Simuler la sauvegarde et retourner au Dashboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Données enregistrées !')),
                        );
                       Navigator.popUntil(context, (route) => route.isFirst);
;
                      },
                      child: const Text('Confirmer'),
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
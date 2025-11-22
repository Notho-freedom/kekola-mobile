// lib/features/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namer_app/app/main_screen.dart';
import '../../app/theme/app_theme.dart';
import '../saisie/saisie_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données simulées pour le test
    const String userName = 'Ousmane';
    final DateTime today = DateTime.now();
    const double yesterdaySales = 1250.75;
    const double yesterdayCash = 980.50;
    final List<double> salesData = [1200, 1300, 1100, 1400, 1250, 1350, 1300]; // 7 jours

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tableau de bord',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message personnalisé
              Text(
                'Salut, $userName !',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              // Date du jour
              Text(
                '${today.day}/${today.month}/${today.year}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              // KPI de la veille
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildKpiCard(
                    context,
                    title: 'Ventes hier',
                    value: '€${yesterdaySales.toStringAsFixed(2)}',
                    icon: Icons.trending_up,
                    color: AppTheme.successColor,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Cash hier',
                    value: '€${yesterdayCash.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // CTA primaire
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SaisieScreen()),
                    );
                  },
                  child: const Text('Nouvelle saisie'),
                ),
              ),
              const SizedBox(height: 24),
              // Mini-graphique (LineChart)
              Text(
                'Ventes sur 7 jours',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false), // Pas d'axes pour un mini-graphique
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: salesData
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.successColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.successColor.withOpacity(0.2),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 1500, // Ajuster selon les données
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bouton vers Insights
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 1)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Voir les insights'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour une carte KPI
  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
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
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
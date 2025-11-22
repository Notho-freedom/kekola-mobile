// lib/features/insights/insights_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données simulées pour les graphiques et KPI
    final List<double> salesData = [1200, 1300, 1100, 1400, 1250, 1350, 1300]; // 7 jours
    final List<double> cashData = [950, 1000, 900, 1050, 980, 1020, 1000];
    const double lastWeekSales = 8200; // Total semaine précédente
    const double lastWeekCash = 6500;

    // Calcul des KPI
    final double totalSales = salesData.reduce((a, b) => a + b);
    final double totalCash = cashData.reduce((a, b) => a + b);
    final double salesVariation = ((totalSales - lastWeekSales) / lastWeekSales * 100);
    final double cashVariation = ((totalCash - lastWeekCash) / lastWeekCash * 100);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Insights',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Vos performances',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Visualisez vos ventes et votre cash',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              // Carte LineChart (Ventes)
              _buildChartCard(
                context,
                title: 'Évolution des ventes (7 jours)',
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '€${value.toInt()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                              return Text(
                                days[value.toInt()],
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
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
                          barWidth: 4,
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
              const SizedBox(height: 16),
              // Carte BarChart (Cash)
              _buildChartCard(
                context,
                title: 'Évolution du cash (7 jours)',
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '€${value.toInt()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                              return Text(
                                days[value.toInt()],
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: cashData
                          .asMap()
                          .entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: AppTheme.accentColor,
                                  width: 10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                      minY: 0,
                      maxY: 1200, // Ajuster selon les données
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // KPI comparatifs
              Text(
                'Comparatifs (cette semaine vs. semaine dernière)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildKpiCard(
                    context,
                    title: 'Ventes totales',
                    value: '€${totalSales.toStringAsFixed(2)}',
                    variation: salesVariation,
                    color: AppTheme.successColor,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Cash total',
                    value: '€${totalCash.toStringAsFixed(2)}',
                    variation: cashVariation,
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Historique condensé
              Text(
                'Historique récent',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildHistoryList(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour une carte de graphique
  Widget _buildChartCard(BuildContext context, {required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // Widget pour une carte KPI
  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required double variation,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                value,
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
                    '${variation.abs().toStringAsFixed(1)}% vs. LW',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: variation >= 0 ? AppTheme.successColor : AppTheme.errorColor,
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

  // Widget pour la liste historique condensée
  Widget _buildHistoryList(BuildContext context) {
    // Données simulées
    final List<Map<String, dynamic>> history = [
      {'date': '27/09/2025', 'sales': 1300.0, 'cash': 1000.0},
      {'date': '26/09/2025', 'sales': 1350.0, 'cash': 1020.0},
      {'date': '25/09/2025', 'sales': 1250.0, 'cash': 980.0},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          leading: const Icon(Icons.history, color: AppTheme.primaryColor),
          title: Text(
            item['date'],
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Ventes: €${item['sales'].toStringAsFixed(2)} | Cash: €${item['cash'].toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        );
      },
    );
  }
}
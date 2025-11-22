// lib/features/graphiques/graphiques_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_theme.dart';

class GraphiquesScreen extends StatelessWidget {
  const GraphiquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données simulées pour les graphiques avancés
    final List<double> weeklySales = [8500, 8200, 7900]; // 3 semaines
    final List<double> weeklyCash = [6800, 6500, 6200];
    final double totalSales = weeklySales.reduce((a, b) => a + b);
    final double totalCash = weeklyCash.reduce((a, b) => a + b);

    return Scaffold(
      appBar: CustomAppBar(title: 'Graphiques avancés', showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Analyses visuelles avancées',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Explorez vos données en détail',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              // PieChart (Répartition ventes/cash)
              _buildChartCard(
                context,
                title: 'Répartition ventes/cash (total)',
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: AppTheme.successColor,
                          value: totalSales,
                          title: '${(totalSales / (totalSales + totalCash) * 100).toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppTheme.accentColor,
                          value: totalCash,
                          title: '${(totalCash / (totalSales + totalCash) * 100).toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // BarChart comparatif (semaines)
              _buildChartCard(
                context,
                title: 'Comparatif ventes/cash (3 semaines)',
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
                              const weeks = ['Sem. 1', 'Sem. 2', 'Sem. 3'];
                              return Text(
                                weeks[value.toInt()],
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(3, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: weeklySales[index],
                              color: AppTheme.successColor,
                              width: 12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: weeklyCash[index],
                              color: AppTheme.accentColor,
                              width: 12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                          barsSpace: 4,
                        );
                      }),
                      minY: 0,
                      maxY: 9000, // Ajuster selon les données
                    ),
                  ),
                ),
              ),
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
}
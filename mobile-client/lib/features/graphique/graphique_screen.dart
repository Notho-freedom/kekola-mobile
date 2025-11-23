// lib/features/graphiques/graphiques_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_theme.dart';
import '../../services/api_service.dart';

class GraphiquesScreen extends StatefulWidget {
  const GraphiquesScreen({super.key});

  @override
  State<GraphiquesScreen> createState() => _GraphiquesScreenState();
}

class _GraphiquesScreenState extends State<GraphiquesScreen> {
  bool _isLoading = true;
  List<double> _weeklySales = [];
  List<double> _weeklyCash = [];
  double _totalSales = 0.0;
  double _totalCash = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGraphData();
  }

  Future<void> _loadGraphData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final graphData = await ApiService.getGraphData();
      setState(() {
        _weeklySales = List<double>.from(
          (graphData['weeklySales'] ?? []).map((e) => e.toDouble())
        );
        _weeklyCash = List<double>.from(
          (graphData['weeklyCash'] ?? []).map((e) => e.toDouble())
        );
        _totalSales = (graphData['totalSales'] ?? 0.0).toDouble();
        _totalCash = (graphData['totalCash'] ?? 0.0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: 'Graphiques avancés', showBackButton: false),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erreur: $_error',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.errorColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGraphData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadGraphData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                      sections: _totalSales == 0 && _totalCash == 0
                          ? []
                          : [
                              PieChartSectionData(
                                color: AppTheme.successColor,
                                value: _totalSales,
                                title: '${(_totalSales / (_totalSales + _totalCash) * 100).toStringAsFixed(1)}%',
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: AppTheme.accentColor,
                                value: _totalCash,
                                title: '${(_totalCash / (_totalSales + _totalCash) * 100).toStringAsFixed(1)}%',
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
                      barGroups: _weeklySales.isEmpty
                          ? []
                          : List.generate(_weeklySales.length, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: _weeklySales[index],
                                    color: AppTheme.successColor,
                                    width: 12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  BarChartRodData(
                                    toY: _weeklyCash[index],
                                    color: AppTheme.accentColor,
                                    width: 12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                                barsSpace: 4,
                              );
                            }),
                      minY: 0,
                      maxY: _weeklySales.isEmpty 
                          ? 9000.0 
                          : ([..._weeklySales, ..._weeklyCash].reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity),
                    ),
                  ),
                ),
              ),
                        ],
                      ),
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
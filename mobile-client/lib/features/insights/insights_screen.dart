// lib/features/insights/insights_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_theme.dart';
import '../../services/api_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  List<double> _salesData = [];
  List<double> _cashData = [];
  double _totalSales = 0.0;
  double _totalCash = 0.0;
  double _salesVariation = 0.0;
  double _cashVariation = 0.0;
  List<dynamic> _recentHistory = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInsightsData();
  }

  Future<void> _loadInsightsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger les stats du dashboard pour les 7 derniers jours
      final dashboardStats = await ApiService.getDashboardStats();
      final salesData = List<double>.from(
        (dashboardStats['salesData'] ?? []).map((e) => e.toDouble())
      );
      final cashData = List<double>.from(
        (dashboardStats['cashData'] ?? []).map((e) => e.toDouble())
      );

      // Charger les métriques pour calculer les variations
      final metrics = await ApiService.getMetrics(range: '14d');
      
      // Calculer les totaux de cette semaine et la semaine dernière
      final now = DateTime.now();
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
      final lastWeekEnd = thisWeekStart;

      double thisWeekSales = 0.0;
      double thisWeekCash = 0.0;
      double lastWeekSales = 0.0;
      double lastWeekCash = 0.0;

      for (var metric in metrics) {
        final date = DateTime.parse(metric['date']);
        final sales = (metric['sales'] ?? 0.0).toDouble();
        final cash = (metric['cash'] ?? 0.0).toDouble();

        if (date.isAfter(thisWeekStart.subtract(const Duration(days: 1)))) {
          thisWeekSales += sales;
          thisWeekCash += cash;
        } else if (date.isAfter(lastWeekStart.subtract(const Duration(days: 1))) && 
                   date.isBefore(lastWeekEnd)) {
          lastWeekSales += sales;
          lastWeekCash += cash;
        }
      }

      // Calculer les variations
      final salesVariation = lastWeekSales > 0 
          ? ((thisWeekSales - lastWeekSales) / lastWeekSales * 100)
          : 0.0;
      final cashVariation = lastWeekCash > 0
          ? ((thisWeekCash - lastWeekCash) / lastWeekCash * 100)
          : 0.0;

      // Récupérer l'historique récent (3 dernières entrées)
      final recentHistory = metrics.take(3).toList();

      setState(() {
        _salesData = salesData;
        _cashData = cashData;
        _totalSales = thisWeekSales;
        _totalCash = thisWeekCash;
        _salesVariation = salesVariation;
        _cashVariation = cashVariation;
        _recentHistory = recentHistory;
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
      appBar: CustomAppBar(
        title: 'Insights',
        showBackButton: false,
      ),
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
                          onPressed: _loadInsightsData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadInsightsData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                          spots: _salesData
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
                      maxY: _salesData.isEmpty 
                          ? 1500.0 
                          : (_salesData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity),
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
                      barGroups: _cashData
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
                      maxY: _cashData.isEmpty 
                          ? 1200.0 
                          : (_cashData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity),
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
                    value: '€${_totalSales.toStringAsFixed(2)}',
                    variation: _salesVariation,
                    color: AppTheme.successColor,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Cash total',
                    value: '€${_totalCash.toStringAsFixed(2)}',
                    variation: _cashVariation,
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
    if (_recentHistory.isEmpty) {
      return Center(
        child: Text(
          'Aucun historique disponible',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentHistory.length,
      itemBuilder: (context, index) {
        final item = _recentHistory[index];
        final date = item['date'] ?? '';
        final sales = (item['sales'] ?? 0.0).toDouble();
        final cash = (item['cash'] ?? 0.0).toDouble();
        
        // Formater la date
        String formattedDate = date;
        try {
          final dateObj = DateTime.parse(date);
          formattedDate = '${dateObj.day}/${dateObj.month}/${dateObj.year}';
        } catch (e) {
          // Garder la date originale
        }
        
        return ListTile(
          leading: const Icon(Icons.history, color: AppTheme.primaryColor),
          title: Text(
            formattedDate,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Ventes: €${sales.toStringAsFixed(2)} | Cash: €${cash.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        );
      },
    );
  }
}
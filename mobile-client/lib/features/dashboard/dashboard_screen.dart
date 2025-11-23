// lib/features/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namer_app/app/main_screen.dart';
import '../../app/theme/app_theme.dart';
import '../saisie/saisie_screen.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _userName = '';
  double _yesterdaySales = 0.0;
  double _yesterdayCash = 0.0;
  List<double> _salesData = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await ApiService.getDashboardStats();
      setState(() {
        _userName = stats['userName'] ?? 'Utilisateur';
        _yesterdaySales = (stats['yesterdaySales'] ?? 0.0).toDouble();
        _yesterdayCash = (stats['yesterdayCash'] ?? 0.0).toDouble();
        _salesData = List<double>.from(
          (stats['salesData'] ?? []).map((e) => e.toDouble())
        );
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
    final DateTime today = DateTime.now();
    
    // Calculer maxY dynamiquement
    final maxY = _salesData.isEmpty 
        ? 1500.0 
        : (_salesData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tableau de bord',
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
                          onPressed: _loadDashboardData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Message personnalisé
                          Text(
                            'Salut, $_userName !',
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
                                value: '€${_yesterdaySales.toStringAsFixed(2)}',
                                icon: Icons.trending_up,
                                color: AppTheme.successColor,
                              ),
                              _buildKpiCard(
                                context,
                                title: 'Cash hier',
                                value: '€${_yesterdayCash.toStringAsFixed(2)}',
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
                                ).then((_) => _loadDashboardData()); // Recharger après retour
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
                              child: _salesData.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Aucune donnée disponible',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    )
                                  : LineChart(
                                      LineChartData(
                                        gridData: const FlGridData(show: false),
                                        titlesData: const FlTitlesData(show: false),
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
                                            barWidth: 3,
                                            dotData: const FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: AppTheme.successColor.withOpacity(0.2),
                                            ),
                                          ),
                                        ],
                                        minY: 0,
                                        maxY: maxY,
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
// lib/features/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:namer_app/app/main_screen.dart';
import '../../app/theme/app_theme.dart';
import '../saisie/saisie_screen.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_kpi_card.dart';
import '../../widgets/animated_gradient_button.dart';
import '../../widgets/glassmorphism_card.dart';

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
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header moderne avec glassmorphism
                          GlassmorphismCard(
                            padding: const EdgeInsets.all(24),
                            margin: EdgeInsets.zero,
                            gradient: AppTheme.primaryGradient,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Salut, $_userName ! 👋',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: Colors.white.withOpacity(0.9),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${today.day}/${today.month}/${today.year}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.wallet,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // KPI de la veille avec animations
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                AnimatedKpiCard(
                                  title: 'Ventes hier',
                                  value: '€${_yesterdaySales.toStringAsFixed(2)}',
                                  icon: Icons.trending_up_rounded,
                                  gradient: AppTheme.successGradient,
                                  onTap: () {},
                                ),
                                AnimatedKpiCard(
                                  title: 'Cash hier',
                                  value: '€${_yesterdayCash.toStringAsFixed(2)}',
                                  icon: Icons.account_balance_wallet_rounded,
                                  gradient: AppTheme.accentGradient,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // CTA primaire avec animation
                          AnimatedGradientButton(
                            text: 'Nouvelle saisie',
                            icon: Icons.add_circle_outline,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SaisieScreen()),
                              ).then((_) => _loadDashboardData());
                            },
                          ),
                          const SizedBox(height: 24),
                          // Mini-graphique (LineChart) moderne
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ventes sur 7 jours',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 16,
                                      color: AppTheme.successColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'En hausse',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.successColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GlassmorphismCard(
                            height: 180,
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(20),
                            child: _salesData.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.show_chart,
                                            size: 32,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Aucune donnée disponible',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                : LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: maxY / 4,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey.shade100,
                                            strokeWidth: 1,
                                            dashArray: [5, 5],
                                          );
                                        },
                                      ),
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
                                          gradient: AppTheme.successGradient,
                                          barWidth: 4,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (spot, percent, barData, index) {
                                              return FlDotCirclePainter(
                                                radius: 5,
                                                color: AppTheme.successColor,
                                                strokeWidth: 3,
                                                strokeColor: Colors.white,
                                              );
                                            },
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                AppTheme.successColor.withOpacity(0.4),
                                                AppTheme.successColor.withOpacity(0.05),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      minY: 0,
                                      maxY: maxY,
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

}
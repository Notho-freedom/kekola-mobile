// lib/app/main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme/app_theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/historique/historique_screen.dart';
import '../features/graphique/graphique_screen.dart';
import '../features/profil/profil_screen.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex = 0;

  // Liste des écrans accessibles via la navigation
  final List<Widget> _screens = [
    const DashboardScreen(),
    const InsightsScreen(),
    const HistoriqueScreen(),
    const GraphiquesScreen(),
    const ProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Vérifier l'authentification périodiquement
    _checkAuthPeriodically();
  }

  // Vérifie l'authentification toutes les 30 secondes (persistance agressive)
  void _checkAuthPeriodically() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.checkAuthStatus().then((_) {
        if (!mounted) return;
        if (!authProvider.isAuthenticated) {
          // Si déconnecté, rediriger vers login
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          // Continuer à vérifier
          _checkAuthPeriodically();
        }
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Si l'utilisateur n'est plus authentifié, rediriger vers login
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondary,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              selectedIconTheme: const IconThemeData(size: 26),
              unselectedIconTheme: const IconThemeData(size: 24),
              items: List.generate(5, (index) {
                final icons = [
                  [Icons.dashboard, Icons.dashboard_outlined],
                  [Icons.insights, Icons.insights_outlined],
                  [Icons.history, Icons.history_outlined],
                  [Icons.bar_chart, Icons.bar_chart_outlined],
                  [Icons.person, Icons.person_outline],
                ];
                final labels = ['Dashboard', 'Insights', 'Historique', 'Graphiques', 'Profil'];
                final isSelected = _selectedIndex == index;
                
                return BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: isSelected
                        ? BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Icon(
                      isSelected ? icons[index][0] : icons[index][1],
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  label: labels[index],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

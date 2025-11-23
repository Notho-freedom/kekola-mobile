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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondary,
            backgroundColor: AppTheme.surfaceColor,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
            unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historique',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Graphiques',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}

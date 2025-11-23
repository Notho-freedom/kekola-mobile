// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'package:namer_app/features/onboarding/onboarding_screen.dart';
import '../providers/auth_provider.dart';
import '../app/main_screen.dart';
import '../features/auth/login_screen.dart';


class CommercantApp extends StatelessWidget {
  const CommercantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commerçant Pro',
      theme: AppTheme.lightTheme, // Thème clair principal
      darkTheme: AppTheme.darkTheme, // Thème sombre optionnel
      debugShowCheckedModeBanner: false, // Cache la bannière debug
      home: const SplashScreen(), // Écran de chargement initial
    );
  }
}

// Écran de splash avec vérification d'authentification
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Attendre un peu pour l'animation
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Attendre que la vérification d'authentification soit terminée
    await authProvider.checkAuthStatus();
    
    if (!mounted) return;
    
    // Naviguer selon l'état d'authentification
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo temporaire
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'COMMERÇANT PRO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gestion simplifiée pour commerçants',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../app/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../../widgets/animated_gradient_button.dart';
import '../../widgets/glassmorphism_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Liste des slides d'onboarding modernisés
  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Bienvenue sur\nCommerçant Pro',
      'description': 'Saisissez vos ventes et votre cash en moins de 60 secondes !',
      'icon': Icons.flash_on_rounded,
      'gradient': AppTheme.primaryGradient,
    },
    {
      'title': 'Visualisez vos\ndonnées',
      'description': 'Suivez vos performances avec des graphiques clairs et modernes.',
      'icon': Icons.insights_rounded,
      'gradient': AppTheme.successGradient,
    },
    {
      'title': 'Synchronisation\nautomatique',
      'description': 'Sauvegardez vos données dans le cloud et accédez-y depuis n\'importe où.',
      'icon': Icons.cloud_sync_rounded,
      'gradient': AppTheme.accentGradient,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE0E7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec logo
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Kekola Mobile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Slides avec PageView
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildSlide(
                      title: _slides[index]['title'] as String,
                      description: _slides[index]['description'] as String,
                      icon: _slides[index]['icon'] as IconData,
                      gradient: _slides[index]['gradient'] as Gradient,
                      index: index,
                    );
                  },
                ),
              ),
              
              // Indicateurs de page modernisés
              _buildPageIndicators(),
              
              const SizedBox(height: 24),
              
              // Boutons d'action
              _buildActionButtons(context),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour un slide individuel modernisé
  Widget _buildSlide({
    required String title,
    required String description,
    required IconData icon,
    required Gradient gradient,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône avec animation et glassmorphism
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, iconValue, child) {
                      return Transform.scale(
                        scale: iconValue,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  
                  // Titre
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -1,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Description dans une carte glassmorphism
                  GlassmorphismCard(
                    padding: const EdgeInsets.all(24),
                    margin: EdgeInsets.zero,
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                            height: 1.6,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Indicateurs de page modernisés
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => TweenAnimationBuilder<double>(
          tween: Tween(
            begin: _currentPage == index ? 0.0 : 1.0,
            end: _currentPage == index ? 1.0 : 0.0,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: _currentPage == index ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? AppTheme.primaryGradient
                    : null,
                color: _currentPage == index
                    ? null
                    : AppTheme.textDisabled,
                borderRadius: BorderRadius.circular(4),
                boxShadow: _currentPage == index
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  // Boutons d'action modernisés
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // Bouton principal avec animation
          AnimatedGradientButton(
            text: _currentPage < _slides.length - 1 ? 'Suivant' : 'Commencer',
            icon: _currentPage < _slides.length - 1
                ? Icons.arrow_forward_rounded
                : Icons.check_circle_rounded,
            onPressed: () {
              if (_currentPage < _slides.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Bouton Passer
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const LoginScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
            child: Text(
              'Passer',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

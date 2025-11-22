// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Liste des slides d'onboarding
  final List<Map<String, String>> _slides = [
    {
      'title': 'Bienvenue sur Commerçant Pro',
      'description': 'Saisissez vos ventes et votre cash en moins de 60 secondes !',
      'icon': 'assets/icons/speed.png', // À remplacer par un asset réel
    },
    {
      'title': 'Visualisez vos données',
      'description': 'Suivez vos performances avec des graphiques clairs et modernes.',
      'icon': 'assets/icons/chart.png',
    },
    {
      'title': 'Travaillez hors-ligne',
      'description': 'Continuez à gérer vos données même sans connexion pendant 48h+.',
      'icon': 'assets/icons/offline.png',
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
                    title: _slides[index]['title']!,
                    description: _slides[index]['description']!,
                    icon: _slides[index]['icon']!,
                  );
                },
              ),
            ),
            // Indicateurs de page
            _buildPageIndicators(),
            // Boutons d'action
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // Widget pour un slide individuel
  Widget _buildSlide({
    required String title,
    required String description,
    required String icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône avec animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image, // Placeholder (remplacer par Image.asset(icon))
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          // Titre
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Indicateurs de page
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppTheme.primaryColor : AppTheme.textDisabled,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // Boutons d'action (Suivant, Passer, Commencer)
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Bouton principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _slides.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              child: Text(
                _currentPage < _slides.length - 1 ? 'Suivant' : 'Commencer',
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton Passer
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'Passer',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
// lib/features/saisie/saisie_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../app/theme/app_theme.dart';
import 'recap_screen.dart';
import '../../widgets/animated_gradient_button.dart';
import '../../widgets/glassmorphism_card.dart';

class SaisieScreen extends StatefulWidget {
  const SaisieScreen({super.key});

  @override
  State<SaisieScreen> createState() => _SaisieScreenState();
}

class _SaisieScreenState extends State<SaisieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salesController = TextEditingController();
  final _cashController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Écouter les changements dans les champs pour activer/désactiver le bouton
    _salesController.addListener(_validateForm);
    _cashController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _salesController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  // Valider si les champs sont non vides
  void _validateForm() {
    setState(() {
      _isFormValid = _salesController.text.isNotEmpty && _cashController.text.isNotEmpty;
    });
  }

  // Gérer la soumission du formulaire
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Naviguer vers l'écran Récap avec les données saisies
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecapScreen(
            sales: double.parse(_salesController.text),
            cash: double.parse(_cashController.text),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Nouvelle saisie',
        showBackButton: true,
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header moderne
                  GlassmorphismCard(
                    padding: const EdgeInsets.all(24),
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_chart_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nouvelle saisie',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        dateStr,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Champ Ventes
                  TextFormField(
                    controller: _salesController,
                    decoration: const InputDecoration(
                      labelText: 'Ventes (€)',
                      prefixIcon: Icon(Icons.trending_up),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer les ventes';
                      }
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Veuillez entrer un montant valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Champ Cash
                  TextFormField(
                    controller: _cashController,
                    decoration: const InputDecoration(
                      labelText: 'Cash (€)',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le cash';
                      }
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Veuillez entrer un montant valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Bouton Valider avec animation
                  AnimatedGradientButton(
                    text: 'Continuer',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _isFormValid ? _handleSubmit : null,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
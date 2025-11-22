// lib/features/saisie/saisie_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import 'recap_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle saisie'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  'Saisissez vos données',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez les ventes et le cash du jour',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
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
                const SizedBox(height: 24),
                // Bouton Valider
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid ? _handleSubmit : null,
                    child: const Text('Valider'),
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
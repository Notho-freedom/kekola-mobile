// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../../app/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Connexion avec l'API backend
Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
      // Naviguer vers MainScreen après connexion réussie
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
        } else {
          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Erreur de connexion'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        automaticallyImplyLeading: false, // Pas de bouton retour
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre
                Text(
                  'Bienvenue !',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour gérer vos ventes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                // Champ Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre e-mail';
                    }
                    // Nettoyer l'email (enlever les espaces)
                    final email = value.trim();
                    if (email.isEmpty) {
                      return 'Veuillez entrer votre e-mail';
                    }
                    // Vérification simple : doit contenir @ et au moins un point après
                    if (!email.contains('@') || !email.contains('.') || email.indexOf('@') >= email.lastIndexOf('.')) {
                      return 'E-mail invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Bouton Connexion
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        child: authProvider.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Se connecter'),
                  ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Lien vers Inscription
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    'Pas de compte ? Inscrivez-vous',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
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
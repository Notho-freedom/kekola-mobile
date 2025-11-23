// lib/features/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../app/main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Inscription avec l'API backend
  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Si l'inscription réussit et que l'utilisateur est connecté, aller au MainScreen
          if (authProvider.isAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          } else {
            // Sinon, aller à l'écran de connexion
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inscription réussie ! Vous pouvez maintenant vous connecter.'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Erreur d\'inscription'),
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
        title: const Text('Inscription'),
        automaticallyImplyLeading: true, // Bouton retour vers onboarding/connexion
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
                  'Créez votre compte',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez Commerçant Pro en quelques secondes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                // Champ Nom
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                // Bouton Inscription
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleSignup,
                        child: authProvider.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('S\'inscrire'),
                  ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Lien vers Connexion
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Déjà un compte ? Connectez-vous',
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
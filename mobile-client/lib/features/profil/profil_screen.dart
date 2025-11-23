// lib/features/profil/profil_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/settings/settings_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _error = null;
    });

    try {
      final user = await ApiService.getCurrentUser();
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  // Mise à jour du profil
  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await ApiService.updateUser(
          name: _nameController.text.isNotEmpty ? _nameController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        );

        setState(() {
          _isLoading = false;
          _passwordController.clear(); // Vider le champ mot de passe après mise à jour
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour !')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  // Déconnexion
  void _handleLogout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Profil', showBackButton: false),
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : _error != null && _nameController.text.isEmpty
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
                          onPressed: _loadProfile,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                // Titre
                Text(
                  'Gérez votre compte',
                  style: Theme.of(context).textTheme.displayMedium,
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
                // Champ Mot de passe (optionnel pour mise à jour)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau mot de passe (optionnel)',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Bouton Mise à jour
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Mettre à jour'),
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton Déconnexion
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text('Se déconnecter'),
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton Paramètres
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: const Text('Paramètres'),
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

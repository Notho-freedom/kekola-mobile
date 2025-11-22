// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Paramètre simulé
  String _theme = 'Clair'; // Paramètre simulé
  String _language = 'Français'; // Paramètre simulé

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Paramètres',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personnalisez votre expérience',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              // Notifications
              SwitchListTile(
                title: Text(
                  'Activer les notifications',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Notifications ${value ? 'activées' : 'désactivées'}',
                      ),
                    ),
                  );
                },
              ),
              // Thème
              ListTile(
                title: Text(
                  'Thème',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  _theme,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                onTap: () {
                  // TODO: Implémenter choix de thème
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Choix de thème à implémenter')),
                  );
                },
              ),
              // Langue
              ListTile(
                title: Text(
                  'Langue',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  _language,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                onTap: () {
                  // TODO: Implémenter choix de langue
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Choix de langue à implémenter')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
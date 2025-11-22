// lib/features/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Notifications simulées
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Ventes élevées',
        'message': 'Vos ventes du 27/09/2025 ont atteint €1300, un record !',
        'time': '10:30',
        'isRead': false,
      },
      {
        'title': 'Cash bas',
        'message': 'Le cash du 25/09/2025 est inférieur à la moyenne.',
        'time': '08:15',
        'isRead': true,
      },
      {
        'title': 'Saisie enregistrée',
        'message': 'Nouvelle saisie confirmée pour le 26/09/2025.',
        'time': '14:00',
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos notifications',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Consultez les alertes récentes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune notification pour le moment.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            color: notification['isRead']
                                ? AppTheme.surfaceColor
                                : AppTheme.primaryColor.withOpacity(0.1),
                            child: ListTile(
                              leading: Icon(
                                notification['isRead']
                                    ? Icons.notifications
                                    : Icons.notifications_active,
                                color: notification['isRead']
                                    ? AppTheme.textSecondary
                                    : AppTheme.primaryColor,
                              ),
                              title: Text(
                                notification['title'],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: notification['isRead']
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                              ),
                              subtitle: Text(
                                '${notification['message']} • ${notification['time']}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              onTap: () {
                                // TODO: Marquer comme lu (future implémentation)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Notification : ${notification['title']}'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
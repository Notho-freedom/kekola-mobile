// lib/features/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await ApiService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      // Recharger les notifications après marquage
      await _loadNotifications();
    } catch (e) {
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

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'À l\'instant';
          }
          return 'Il y a ${difference.inMinutes} min';
        }
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        final day = dateTime.day.toString().padLeft(2, '0');
        final month = dateTime.month.toString().padLeft(2, '0');
        final year = dateTime.year;
        return '$day/$month/$year';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : _error != null
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
                          onPressed: _loadNotifications,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
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
                            child: _notifications.isEmpty
                                ? Center(
                                    child: Text(
                                      'Aucune notification pour le moment.',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification = _notifications[index];
                                      final isRead = notification['is_read'] ?? false;
                                      final createdAt = notification['created_at'] ?? '';
                                      final timeText = _formatTime(createdAt);
                                      
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                                        color: isRead
                                            ? AppTheme.surfaceColor
                                            : AppTheme.primaryColor.withOpacity(0.1),
                                        child: ListTile(
                                          leading: Icon(
                                            isRead
                                                ? Icons.notifications
                                                : Icons.notifications_active,
                                            color: isRead
                                                ? AppTheme.textSecondary
                                                : AppTheme.primaryColor,
                                          ),
                                          title: Text(
                                            notification['title'] ?? '',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: isRead
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                                ),
                                          ),
                                          subtitle: Text(
                                            '${notification['message'] ?? ''} • $timeText',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                          onTap: () {
                                            if (!isRead) {
                                              _markAsRead(notification['id']);
                                            }
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
      ),
    );
  }
}
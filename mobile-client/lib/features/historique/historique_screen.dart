// lib/features/historique/historique_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../services/api_service.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filter = 'Tous'; // Filtres possibles : 'Tous', 'Semaine', 'Mois'
  List<dynamic> _allTransactions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger plus de données pour avoir l'historique complet
      final metrics = await ApiService.getMetrics(range: '90d'); // 90 jours
      setState(() {
        _allTransactions = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Filtrer et chercher dans les transactions
  List<dynamic> _filteredTransactions() {
    var filtered = _allTransactions.where((t) {
      if (_filter == 'Semaine') {
        // Filtre dernière semaine
        final date = DateTime.parse(t['date']);
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        return date.isAfter(weekAgo);
      } else if (_filter == 'Mois') {
        // Filtre dernier mois
        final date = DateTime.parse(t['date']);
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        return date.isAfter(monthAgo);
      }
      return true;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final dateStr = t['date']?.toString() ?? '';
        final salesStr = t['sales']?.toString() ?? '';
        final cashStr = t['cash']?.toString() ?? '';
        return dateStr.contains(_searchQuery) ||
            salesStr.contains(_searchQuery) ||
            cashStr.contains(_searchQuery);
      }).toList();
    }

    return filtered.toList();
  }

  // Afficher les détails d'une transaction
  void _showTransactionDetails(dynamic transaction) {
    final date = transaction['date'] ?? '';
    final sales = (transaction['sales'] ?? 0.0).toDouble();
    final cash = (transaction['cash'] ?? 0.0).toDouble();
    final deltas = transaction['deltas'] ?? {};
    final salesDelta = (deltas['sales'] ?? 0.0).toDouble();
    final cashDelta = (deltas['cash'] ?? 0.0).toDouble();

    // Formater la date
    String formattedDate = date;
    try {
      final dateObj = DateTime.parse(date);
      formattedDate = '${dateObj.day}/${dateObj.month}/${dateObj.year}';
    } catch (e) {
      // Garder la date originale si le parsing échoue
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Détails de la transaction du $formattedDate',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ventes : €${sales.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.successColor,
                    ),
              ),
              Text(
                'Cash : €${cash.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.accentColor,
                    ),
              ),
              if (deltas.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Variation ventes : ${salesDelta >= 0 ? '+' : ''}${salesDelta.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: salesDelta >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                ),
                Text(
                  'Variation cash : ${cashDelta >= 0 ? '+' : ''}${cashDelta.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cashDelta >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions();

    return Scaffold(
      appBar: CustomAppBar(title: 'Historique', showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Historique des transactions',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Consultez toutes vos saisies',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              // Barre de recherche
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Rechercher (date ou montant)',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Filtres
              Row(
                children: [
                  Text(
                    'Filtre : ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _filter,
                    items: ['Tous', 'Semaine', 'Mois']
                        .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _filter = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Liste des transactions
              Expanded(
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
                                  onPressed: _loadTransactions,
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucune transaction trouvée.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadTransactions,
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final transaction = filtered[index];
                                    final date = transaction['date'] ?? '';
                                    final sales = (transaction['sales'] ?? 0.0).toDouble();
                                    final cash = (transaction['cash'] ?? 0.0).toDouble();
                                    
                                    // Formater la date
                                    String formattedDate = date;
                                    try {
                                      final dateObj = DateTime.parse(date);
                                      formattedDate = '${dateObj.day}/${dateObj.month}/${dateObj.year}';
                                    } catch (e) {
                                      // Garder la date originale
                                    }
                                    
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.history,
                                          color: AppTheme.primaryColor,
                                          size: 30,
                                        ),
                                        title: Text(
                                          formattedDate,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ventes : €${sales.toStringAsFixed(2)}',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: AppTheme.successColor,
                                                  ),
                                            ),
                                            Text(
                                              'Cash : €${cash.toStringAsFixed(2)}',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: AppTheme.accentColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        onTap: () => _showTransactionDetails(transaction),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
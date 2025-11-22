// lib/features/historique/historique_screen.dart

import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filter = 'Tous'; // Filtres possibles : 'Tous', 'Semaine', 'Mois'

  @override
  void initState() {
    super.initState();
    // Simuler un chargement de données (ex. : depuis une base locale)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Filtrer et chercher dans les transactions
  List<Map<String, dynamic>> _filteredTransactions(List<Map<String, dynamic>> all) {
    var filtered = all.where((t) {
      if (_filter == 'Semaine') {
        // Simuler filtre dernière semaine (basé sur dates récentes)
        return int.parse(t['date'].split('/')[0]) >= 22; // Ex. : jours >= 22
      } else if (_filter == 'Mois') {
        // Simuler filtre dernier mois
        return int.parse(t['date'].split('/')[1]) == 9; // Ex. : septembre
      }
      return true;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return t['date'].contains(_searchQuery) ||
            t['sales'].toString().contains(_searchQuery) ||
            t['cash'].toString().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  // Afficher les détails d'une transaction
  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Détails de la transaction du ${transaction['date']}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ventes : €${transaction['sales'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.successColor,
                    ),
              ),
              Text(
                'Cash : €${transaction['cash'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.accentColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Variation ventes : +5% (simulée)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Variation cash : -2% (simulée)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Notes : Aucune note ajoutée.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
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
    // Données simulées pour l'historique
    final List<Map<String, dynamic>> transactions = [
      {'date': '27/09/2025', 'sales': 1300.0, 'cash': 1000.0},
      {'date': '26/09/2025', 'sales': 1350.0, 'cash': 1020.0},
      {'date': '25/09/2025', 'sales': 1250.0, 'cash': 980.0},
      {'date': '24/09/2025', 'sales': 1400.0, 'cash': 1050.0},
      {'date': '23/09/2025', 'sales': 1100.0, 'cash': 900.0},
      {'date': '22/09/2025', 'sales': 1200.0, 'cash': 950.0},
      {'date': '21/09/2025', 'sales': 1300.0, 'cash': 1000.0},
      {'date': '20/09/2025', 'sales': 1150.0, 'cash': 920.0},
      {'date': '15/08/2025', 'sales': 1000.0, 'cash': 800.0}, // Pour tester filtre mois
    ];

    final filtered = _filteredTransactions(transactions);

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
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Aucune transaction trouvée.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final transaction = filtered[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.history,
                                    color: AppTheme.primaryColor,
                                    size: 30,
                                  ),
                                  title: Text(
                                    transaction['date'],
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ventes : €${transaction['sales'].toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.successColor,
                                            ),
                                      ),
                                      Text(
                                        'Cash : €${transaction['cash'].toStringAsFixed(2)}',
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
            ],
          ),
        ),
      ),
    );
  }
}
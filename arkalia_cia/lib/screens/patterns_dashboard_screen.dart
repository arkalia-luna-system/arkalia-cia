import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../services/backend_config_service.dart';

class PatternsDashboardScreen extends StatefulWidget {
  const PatternsDashboardScreen({super.key});

  @override
  State<PatternsDashboardScreen> createState() => _PatternsDashboardScreenState();
}

class _PatternsDashboardScreenState extends State<PatternsDashboardScreen> {
  Map<String, dynamic>? _patterns;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Récupérer données depuis documents et consultations
      final url = await BackendConfigService.getBackendURL();
      if (url.isEmpty) {
        setState(() {
          _error = 'Backend non configuré';
          _isLoading = false;
        });
        return;
      }

      final documentsResponse = await http.get(
        Uri.parse('$url/api/documents?limit=100'),
        headers: {'Content-Type': 'application/json'},
      );

      if (documentsResponse.statusCode != 200) {
        setState(() {
          _error = 'Erreur lors de la récupération des documents';
          _isLoading = false;
        });
        return;
      }

      final documents = jsonDecode(documentsResponse.body) as List;
      
      // Convertir en format pour analyse
      final data = documents.map((doc) {
        return {
          'date': doc['created_at'],
          'type': doc['category'] ?? 'document',
          'value': 1,
        };
      }).toList();

      // Analyser patterns
      final response = await http.post(
        Uri.parse('$url/api/patterns/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': data}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        setState(() {
          _patterns = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors de l\'analyse';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse Patterns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatterns,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPatterns,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _patterns == null
                  ? const Center(child: Text('Aucune donnée disponible'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            'Patterns Récurrents',
                            _patterns!['recurring_patterns'] ?? [],
                          ),
                          const SizedBox(height: 24),
                          _buildTrendsSection(_patterns!['trends'] ?? {}),
                          const SizedBox(height: 24),
                          _buildSeasonalitySection(_patterns!['seasonality'] ?? {}),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Text('Aucun pattern récurrent détecté')
            else
              ...items.map((item) => _buildPatternItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(Map<String, dynamic> pattern) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.repeat,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(pattern['type'] ?? 'Inconnu'),
      subtitle: Text('Fréquence: ${pattern['frequency_days']} jours'),
      trailing: Chip(
        label: Text('${((pattern['confidence'] ?? 0) * 100).toStringAsFixed(0)}%'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildTrendsSection(Map<String, dynamic> trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendances',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (trends.isEmpty)
              const Text('Aucune tendance détectée')
            else
              Column(
                children: [
                  _buildTrendItem('Direction', trends['direction'] ?? 'stable'),
                  _buildTrendItem('Force', trends['strength']?.toStringAsFixed(2) ?? '0'),
                  _buildTrendItem('Pente', trends['slope']?.toStringAsFixed(2) ?? '0'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalitySection(Map<String, dynamic> seasonality) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saisonnalité',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (seasonality.isEmpty)
              const Text('Aucune saisonnalité détectée')
            else
              Column(
                children: [
                  if (seasonality['peak_month'] != null)
                    _buildTrendItem(
                      'Mois de pic',
                      _getMonthName(seasonality['peak_month']),
                    ),
                  if (seasonality['peak_count'] != null)
                    _buildTrendItem(
                      'Nombre occurrences',
                      seasonality['peak_count'].toString(),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return months[month - 1];
  }
}


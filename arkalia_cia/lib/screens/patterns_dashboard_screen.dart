import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/backend_config_service.dart';
import '../services/offline_cache_service.dart';
import '../services/auth_api_service.dart';
import '../services/pathology_service.dart';
import '../services/medication_service.dart';
import '../utils/error_helper.dart';

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
      // Vérifier le cache d'abord
      const cacheKey = 'patterns_analysis';
      final cachedPatterns = await OfflineCacheService.getCachedData(cacheKey);
      if (cachedPatterns != null) {
        setState(() {
          _patterns = cachedPatterns as Map<String, dynamic>;
          _isLoading = false;
        });
        return;
      }

      // Récupérer données depuis plusieurs sources
      final List<Map<String, dynamic>> data = [];
      
      // 1. Documents
      final documents = await ApiService.getDocuments();
      for (final doc in documents) {
        data.add({
          'date': doc['created_at'] ?? doc['createdAt'] ?? DateTime.now().toIso8601String(),
          'type': 'document',
          'value': 1,
        });
      }
      
      // 2. Pathologies et leur tracking
      try {
        final pathologyService = PathologyService();
        final pathologies = await pathologyService.getAllPathologies();
        for (final pathology in pathologies) {
          // Ajouter la création de la pathologie
          data.add({
            'date': pathology.createdAt.toIso8601String(),
            'type': 'pathologie',
            'value': 1,
          });
          
          // Ajouter les entrées de tracking
          final tracking = await pathologyService.getTrackingByPathology(
            pathology.id!,
            startDate: DateTime.now().subtract(const Duration(days: 365)),
          );
          for (final entry in tracking) {
            final painLevel = entry.data['painLevel'] ?? entry.data['pain_level'];
            if (painLevel != null) {
              data.add({
                'date': entry.date.toIso8601String(),
                'type': 'douleur',
                'value': painLevel is num ? painLevel.toDouble() : 1.0,
              });
            }
          }
        }
      } catch (e) {
        // Ignorer les erreurs de pathologies
      }
      
      // 3. Médicaments
      try {
        final medicationService = MedicationService();
        final medications = await medicationService.getAllMedications();
        for (final medication in medications) {
          data.add({
            'date': medication.startDate.toIso8601String(),
            'type': 'medicament',
            'value': 1,
          });
        }
      } catch (e) {
        // Ignorer les erreurs de médicaments
      }
      
      if (data.isEmpty) {
        setState(() {
          _error = 'Aucune donnée disponible pour l\'analyse.\n\nAjoutez des documents, pathologies ou médicaments pour voir des patterns.';
          _isLoading = false;
        });
        return;
      }

      // Analyser patterns avec authentification et gestion automatique du refresh token
      final url = await BackendConfigService.getBackendURL();
      final response = await _makeAuthenticatedPatternRequest(() async {
        final patternHeaders = <String, String>{
          'Content-Type': 'application/json',
        };
        final token = await AuthApiService.getAccessToken();
        if (token != null) {
          patternHeaders['Authorization'] = 'Bearer $token';
        }
        return await http.post(
          Uri.parse('$url/api/v1/patterns/analyze'),
          headers: patternHeaders,
          body: jsonEncode({'data': data}),
        ).timeout(const Duration(seconds: 30));
      });

      final patterns = response as Map<String, dynamic>;
      setState(() {
        _patterns = patterns;
        _isLoading = false;
      });
      // Mettre en cache les résultats (durée: 6 heures)
      await OfflineCacheService.cacheData(
        cacheKey,
        patterns,
        duration: const Duration(hours: 6),
      );
    } catch (e) {
      ErrorHelper.logError('PatternsDashboardScreen._loadPatterns', e);
      setState(() {
        _error = ErrorHelper.getUserFriendlyMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _sharePatterns() async {
    if (_patterns == null) return;
    
    try {
      // Formater les patterns en texte lisible
      final buffer = StringBuffer();
      buffer.writeln('ANALYSE PATTERNS - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
      buffer.writeln('=' * 50);
      buffer.writeln();
      
      // Patterns récurrents
      final recurring = _patterns!['recurring_patterns'] as List?;
      if (recurring != null && recurring.isNotEmpty) {
        buffer.writeln('PATTERNS RÉCURRENTS:');
        for (var pattern in recurring) {
          buffer.writeln('• ${pattern['type'] ?? 'Inconnu'}: Tous les ${pattern['frequency_days'] ?? '?'} jours (Confiance: ${((pattern['confidence'] ?? 0) * 100).toStringAsFixed(0)}%)');
        }
        buffer.writeln();
      }
      
      // Tendances
      final trends = _patterns!['trends'] as Map?;
      if (trends != null && trends.isNotEmpty) {
        buffer.writeln('TENDANCES:');
        buffer.writeln('• Direction: ${trends['direction'] ?? 'stable'}');
        buffer.writeln('• Force: ${trends['strength']?.toStringAsFixed(2) ?? '0'}');
        buffer.writeln();
      }
      
      // Saisonnalité
      final seasonality = _patterns!['seasonality'] as Map?;
      if (seasonality != null && seasonality.isNotEmpty) {
        buffer.writeln('SAISONNALITÉ:');
        buffer.writeln('• Période: ${seasonality['period'] ?? '?'} jours');
        buffer.writeln('• Amplitude: ${seasonality['amplitude']?.toStringAsFixed(2) ?? '0'}');
        buffer.writeln();
      }
      
      // Prédictions
      final predictions = _patterns!['predictions'] as Map?;
      if (predictions != null && predictions.isNotEmpty) {
        buffer.writeln('PRÉDICTIONS:');
        buffer.writeln('• Prochaine valeur estimée: ${predictions['next_value']?.toStringAsFixed(2) ?? '?'}');
        buffer.writeln('• Date: ${predictions['next_date'] ?? '?'}');
        buffer.writeln();
      }
      
      await SharePlus.instance.share(
        ShareParams(
          text: buffer.toString(),
        ),
      );
    } catch (e) {
      ErrorHelper.logError('PatternsDashboardScreen._sharePatterns', e);
      if (mounted) {
        final userMessage = ErrorHelper.getUserFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $userMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Méthode helper pour faire des requêtes authentifiées avec gestion du refresh token
  /// Utilisée par _loadPatterns() pour gérer l'authentification automatique
  Future<dynamic> _makeAuthenticatedPatternRequest(
    Future<http.Response> Function() makeRequest,
  ) async {
    try {
      var response = await makeRequest();

      // Si 401 (Unauthorized), essayer de rafraîchir le token
      if (response.statusCode == 401) {
        final refreshResult = await AuthApiService.refreshToken();

        if (refreshResult['success'] == true) {
          // Token rafraîchi, réessayer la requête
          response = await makeRequest();
        } else {
          // Refresh échoué, déconnecter l'utilisateur
          await AuthApiService.logout();
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        if (body.isEmpty) {
          return {};
        }
        final decoded = json.decode(body);
        // Vérifier si la réponse contient une erreur
        if (decoded is Map && decoded.containsKey('error')) {
          throw Exception(decoded['error'] as String? ?? 'Erreur lors de l\'analyse');
        }
        return decoded;
      } else {
        try {
          final errorData = json.decode(response.body);
          final detail = errorData['detail'] ?? errorData['message'] ?? 'Erreur HTTP ${response.statusCode}';
          throw Exception(detail);
        } catch (e) {
          if (e is Exception) {
            rethrow;
          }
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e.toString().contains('Session expirée')) {
        rethrow;
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse Patterns'),
        actions: [
          if (_patterns != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Partager les patterns',
              onPressed: _sharePatterns,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser les patterns',
            onPressed: _loadPatterns,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        // Suggestions selon le type d'erreur
                        if (_error!.toLowerCase().contains('données insuffisantes') ||
                            _error!.toLowerCase().contains('aucune donnée'))
                          Card(
                            color: Colors.blue[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.blue),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Conseil:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Ajoutez au moins 3 documents, pathologies ou médicaments pour voir des patterns.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_error!.toLowerCase().contains('backend') ||
                            _error!.toLowerCase().contains('connexion'))
                          Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.wifi_off, color: Colors.orange),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Vérifiez:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '1. Le backend est démarré\n2. L\'URL est correcte dans les paramètres\n3. Votre connexion réseau',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadPatterns,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
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
                          if (_patterns!['predictions'] != null &&
                              (_patterns!['predictions'] as Map).isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildPredictionsSection(_patterns!['predictions'] ?? {}),
                          ],
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

  Widget _buildPredictionsSection(Map<String, dynamic> predictions) {
    final predictionsList = predictions['predictions'] as List? ?? [];
    final trend = predictions['trend'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prédictions (${predictions['periods'] ?? 30} jours)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (trend.isNotEmpty) ...[
              _buildTrendItem('Direction', trend['direction'] ?? 'stable'),
              _buildTrendItem('Force', trend['strength']?.toStringAsFixed(2) ?? '0'),
              const SizedBox(height: 16),
            ],
            if (predictionsList.isEmpty)
              const Text('Aucune prédiction disponible')
            else
              ...predictionsList.take(5).map((pred) => _buildPredictionItem(pred, trend)),
            if (predictionsList.length > 5)
              Text(
                '... et ${predictionsList.length - 5} autres prédictions',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(Map<String, dynamic> prediction, Map<String, dynamic> trend) {
    final date = DateTime.tryParse(prediction['date'] ?? '');
    final value = prediction['predicted_value'] ?? 0.0;
    final lower = prediction['lower_bound'] ?? 0.0;
    final upper = prediction['upper_bound'] ?? 0.0;
    final direction = trend['direction'] ?? 'stable';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Date inconnue',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Valeur: ${value.toStringAsFixed(2)} (${lower.toStringAsFixed(2)} - ${upper.toStringAsFixed(2)})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              direction == 'increasing' ? '↑' : direction == 'decreasing' ? '↓' : '→',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: direction == 'increasing'
                ? Colors.green.withOpacity( 0.2)
                : direction == 'decreasing'
                    ? Colors.red.withOpacity( 0.2)
                    : Colors.grey.withOpacity( 0.2),
          ),
        ],
      ),
    );
  }
}


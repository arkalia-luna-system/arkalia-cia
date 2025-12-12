import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/pathology_service.dart';
import '../models/pathology.dart';
import '../models/pathology_tracking.dart';
import 'pathology_tracking_screen.dart';

class PathologyDetailScreen extends StatefulWidget {
  final int pathologyId;

  const PathologyDetailScreen({
    super.key,
    required this.pathologyId,
  });

  @override
  State<PathologyDetailScreen> createState() => _PathologyDetailScreenState();
}

class _PathologyDetailScreenState extends State<PathologyDetailScreen> {
  final PathologyService _pathologyService = PathologyService();
  Pathology? _pathology;
  List<PathologyTracking> _trackingEntries = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pathology = await _pathologyService.getPathologyById(widget.pathologyId);
      final tracking = await _pathologyService.getTrackingByPathology(widget.pathologyId);
      
      // Calculer les stats sur les 30 derniers jours
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final stats = await _pathologyService.getPathologyStats(
        widget.pathologyId,
        startDate,
        endDate,
      );

      if (mounted) {
        setState(() {
          _pathology = pathology;
          _trackingEntries = tracking;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails'),
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_pathology == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails'),
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Pathologie introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pathology!.name),
        backgroundColor: _pathology!.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PathologyTrackingScreen(
                    pathologyId: widget.pathologyId,
                  ),
                ),
              );
              _loadData();
            },
            tooltip: 'Ajouter une entrée',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            if (_pathology!.description != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_pathology!.description!),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Statistiques
            if (_stats.isNotEmpty) ...[
              _buildStatsSection(),
              const SizedBox(height: 16),
            ],

            // Graphique douleur (si disponible)
            if (_hasPainData()) ...[
              _buildPainChart(),
              const SizedBox(height: 16),
            ],

            // Symptômes
            if (_pathology!.symptoms.isNotEmpty) ...[
              _buildSectionTitle('Symptômes'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pathology!.symptoms.map((symptom) {
                  return Chip(
                    label: Text(symptom),
                    backgroundColor: _pathology!.color.withValues(alpha:0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Traitements
            if (_pathology!.treatments.isNotEmpty) ...[
              _buildSectionTitle('Traitements'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pathology!.treatments.map((treatment) {
                  return Chip(
                    label: Text(treatment),
                    backgroundColor: Colors.green.withValues(alpha:0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Examens
            if (_pathology!.exams.isNotEmpty) ...[
              _buildSectionTitle('Examens'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pathology!.exams.map((exam) {
                  return Chip(
                    label: Text(exam),
                    backgroundColor: Colors.blue.withValues(alpha:0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Historique des entrées
            _buildSectionTitle('Historique des entrées'),
            if (_trackingEntries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Aucune entrée enregistrée',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._trackingEntries.take(10).map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: _pathology!.color,
                    ),
                    title: Text(
                      _formatDate(entry.date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.data.containsKey('painLevel'))
                          Text(
                            'Douleur: ${entry.data['painLevel']}/10',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        if (entry.data.containsKey('symptoms'))
                          Text(
                            'Symptômes: ${_formatList(entry.data['symptoms'])}',
                          ),
                        if (entry.notes != null && entry.notes!.isNotEmpty)
                          Text(entry.notes!),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _pathology?.color ?? Colors.purple,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Statistiques (30 derniers jours)'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Entrées',
                  '${_stats['total_entries'] ?? 0}',
                  Icons.assignment,
                ),
                if (_stats['average_pain_level'] != null &&
                    (_stats['average_pain_level'] as num) > 0)
                  _buildStatItem(
                    'Douleur moy.',
                    '${(_stats['average_pain_level'] as num).toStringAsFixed(1)}/10',
                    Icons.warning,
                    Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, color: color ?? _pathology?.color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? _pathology?.color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  bool _hasPainData() {
    return _trackingEntries.any((entry) => entry.data.containsKey('painLevel'));
  }

  Widget _buildPainChart() {
    final painData = _trackingEntries
        .where((entry) => entry.data.containsKey('painLevel'))
        .take(30)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (painData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Évolution de la douleur'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: painData.asMap().entries.map((entry) {
                        final pain = entry.value.data['painLevel'];
                        final painValue = pain is num ? pain.toDouble() : 0.0;
                        return FlSpot(entry.key.toDouble(), painValue);
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatList(dynamic list) {
    if (list is List) {
      return list.join(', ');
    }
    return list.toString();
  }
}


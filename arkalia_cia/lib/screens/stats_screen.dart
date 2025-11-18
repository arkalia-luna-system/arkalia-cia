import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/calendar_service.dart';

/// Écran de statistiques de l'application
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final documents = await LocalStorageService.getDocuments();
      final reminders = await LocalStorageService.getReminders();
      final contacts = await LocalStorageService.getEmergencyContacts();
      final upcomingReminders = await CalendarService.getUpcomingReminders();

      // Calculer les statistiques
      final completedReminders = reminders.where((r) => r['is_completed'] == true).length;
      final pendingReminders = reminders.length - completedReminders;
      
      // Documents par catégorie
      final docsByCategory = <String, int>{};
      for (final doc in documents) {
        final category = doc['category'] ?? 'Non catégorisé';
        docsByCategory[category] = (docsByCategory[category] ?? 0) + 1;
      }

      // Taille totale des documents
      final totalSize = documents.fold<int>(
        0,
        (sum, doc) => sum + (doc['file_size'] as int? ?? 0),
      );

      if (mounted) {
        setState(() {
          _stats = {
            'documents': {
              'total': documents.length,
              'by_category': docsByCategory,
              'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
            },
            'reminders': {
              'total': reminders.length,
              'completed': completedReminders,
              'pending': pendingReminders,
              'upcoming': upcomingReminders.length,
            },
            'contacts': {
              'total': contacts.length,
              'primary': contacts.where((c) => c['is_primary'] == true).length,
            },
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.blue[600],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCard(
                      'Documents',
                      Icons.description,
                      Colors.green,
                      [
                        _StatItem('Total', '${_stats['documents']?['total'] ?? 0}'),
                        _StatItem('Taille totale', '${_stats['documents']?['total_size_mb'] ?? '0'} MB'),
                        if (_stats['documents']?['by_category'] != null)
                          ...(_stats['documents']!['by_category'] as Map<String, int>)
                              .entries
                              .map((e) => _StatItem(e.key, '${e.value}')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Rappels',
                      Icons.notifications,
                      Colors.orange,
                      [
                        _StatItem('Total', '${_stats['reminders']?['total'] ?? 0}'),
                        _StatItem('Terminés', '${_stats['reminders']?['completed'] ?? 0}'),
                        _StatItem('En attente', '${_stats['reminders']?['pending'] ?? 0}'),
                        _StatItem('À venir', '${_stats['reminders']?['upcoming'] ?? 0}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Contacts d\'urgence',
                      Icons.contacts,
                      Colors.red,
                      [
                        _StatItem('Total', '${_stats['contacts']?['total'] ?? 0}'),
                        _StatItem('Principaux', '${_stats['contacts']?['primary'] ?? 0}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    IconData icon,
    Color color,
    List<_StatItem> items,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  _StatItem(this.label, this.value);
}


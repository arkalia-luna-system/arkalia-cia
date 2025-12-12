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
    setState(() {
      _isLoading = true;
    });
    
    try {
      final documents = await LocalStorageService.getDocuments();
      final reminders = await LocalStorageService.getReminders();
      final contacts = await LocalStorageService.getEmergencyContacts();
      
      // Récupérer les rappels du calendrier (mobile seulement)
      List<Map<String, dynamic>> calendarReminders = [];
      try {
        calendarReminders = await CalendarService.getUpcomingReminders();
      } catch (e) {
        // Ignorer les erreurs de calendrier
      }

      // Calculer les statistiques des rappels
      final completedReminders = reminders.where((r) => r['is_completed'] == true).length;
      final pendingReminders = reminders.where((r) => r['is_completed'] != true).length;
      
      // Calculer les rappels à venir (locaux + calendrier)
      final now = DateTime.now();
      final upcomingLocal = reminders.where((r) {
        if (r['is_completed'] == true) return false;
        try {
          final dateStr = r['reminder_date'] as String?;
          if (dateStr == null || dateStr.isEmpty) return false;
          final reminderDate = DateTime.parse(dateStr);
          return reminderDate.isAfter(now);
        } catch (e) {
          return false;
        }
      }).length;
      
      final totalUpcoming = upcomingLocal + calendarReminders.length;

      // Documents par catégorie
      final docsByCategory = <String, int>{};
      for (final doc in documents) {
        final category = doc['category'] as String?;
        final cat = category?.isNotEmpty == true ? category! : 'Non catégorisé';
        docsByCategory[cat] = (docsByCategory[cat] ?? 0) + 1;
      }

      // Taille totale des documents
      final totalSize = documents.fold<int>(
        0,
        (sum, doc) => sum + ((doc['file_size'] as num?)?.toInt() ?? 0),
      );
      
      final totalSizeMB = totalSize / (1024 * 1024);
      final sizeDisplay = totalSizeMB < 0.01 
          ? '0 MB' 
          : totalSizeMB < 1 
              ? '${(totalSizeMB * 1024).toStringAsFixed(0)} KB'
              : '${totalSizeMB.toStringAsFixed(2)} MB';

      if (mounted) {
        setState(() {
          _stats = {
            'documents': {
              'total': documents.length,
              'by_category': docsByCategory,
              'total_size': sizeDisplay,
            },
            'reminders': {
              'total': reminders.length,
              'completed': completedReminders,
              'pending': pendingReminders,
              'upcoming': totalUpcoming,
            },
            'contacts': {
              'total': contacts.length,
              'primary': contacts.where((c) => c['is_ice'] == true || c['is_primary'] == true).length,
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
                        _StatItem('Taille totale', _stats['documents']?['total_size'] ?? '0 MB'),
                        if (_stats['documents']?['by_category'] != null && 
                            (_stats['documents']!['by_category'] as Map).isNotEmpty)
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
                      Icons.emergency,
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha:0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
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
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  _StatItem(this.label, this.value);
}


import 'package:flutter/material.dart';
import '../models/hydration_tracking.dart';
import '../services/hydration_service.dart';

/// Écran de gestion des rappels d'hydratation
class HydrationRemindersScreen extends StatefulWidget {
  const HydrationRemindersScreen({super.key});

  @override
  State<HydrationRemindersScreen> createState() => _HydrationRemindersScreenState();
}

class _HydrationRemindersScreenState extends State<HydrationRemindersScreen> {
  final HydrationService _hydrationService = HydrationService();
  Map<String, dynamic>? _dailyProgress;
  List<HydrationEntry> _todayEntries = [];
  HydrationGoal? _goal;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final progress = await _hydrationService.getDailyProgress(_selectedDate);
      final entries = await _hydrationService.getHydrationEntries(_selectedDate);
      final goal = await _hydrationService.getHydrationGoal();

      if (mounted) {
        setState(() {
          _dailyProgress = progress;
          _todayEntries = entries;
          _goal = goal;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Erreur lors du chargement: $e');
      }
    }
  }

  Future<void> _markAsDrank(int amount) async {
    try {
      await _hydrationService.markAsDrank(amount);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$amount ml enregistrés'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  Future<void> _showGoalDialog() async {
    final goalController = TextEditingController(
      text: _goal?.dailyGoal.toString() ?? '2000',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Objectif quotidien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: goalController,
              decoration: const InputDecoration(
                labelText: 'Objectif (ml)',
                border: OutlineInputBorder(),
                helperText: '1 verre = 250ml, 8 verres = 2000ml',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Équivalent: ${(int.tryParse(goalController.text) ?? 2000) / 250} verres',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(goalController.text);
              if (goal != null && goal > 0) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Valeur invalide')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true) {
      final goal = int.tryParse(goalController.text);
      if (goal != null && goal > 0) {
        try {
          await _hydrationService.updateHydrationGoal(
            HydrationGoal(dailyGoal: goal),
          );
          _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Objectif mis à jour')),
            );
          }
        } catch (e) {
          _showError('Erreur: $e');
        }
      }
    }
  }

  Future<void> _showWeeklyChart() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final stats = await _hydrationService.getStatistics(weekAgo, now);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques de la semaine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total bu', '${stats['total_amount']} ml'),
            _buildStatRow('Moyenne quotidienne', '${stats['average_daily']} ml'),
            _buildStatRow('Jours avec entrées', '${stats['days_with_entries']}'),
            _buildStatRow('Jours objectif atteint', '${stats['days_goal_reached']}'),
            _buildStatRow('Taux de conformité', '${stats['compliance_rate']}%'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stats['compliance_rate'] / 100,
              minHeight: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _dailyProgress ?? {};
    final total = progress['total'] as int? ?? 0;
    final goal = progress['goal'] as int? ?? 2000;
    final percentage = progress['percentage'] as int? ?? 0;
    final glasses = progress['glasses'] as int? ?? 0;
    final goalGlasses = progress['goal_glasses'] as int? ?? 8;
    final isGoalReached = progress['is_goal_reached'] as bool? ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('💧 Rappels Hydratation'),
        backgroundColor: Colors.cyan[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showWeeklyChart,
            tooltip: 'Statistiques',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showGoalDialog,
            tooltip: 'Objectif',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélecteur de date
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date sélectionnée'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                            _loadData();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Objectif et progression
                  Card(
                    color: isGoalReached ? Colors.green[50] : Colors.cyan[50],
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          if (isGoalReached) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                                SizedBox(width: 8),
                                Text(
                                  'Hydratation parfaite !',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            '$glasses / $goalGlasses verres',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$total ml / $goal ml',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 24,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isGoalReached ? Colors.green : Colors.cyan,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isGoalReached && progress['remaining'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Il reste ${progress['remaining']} ml à boire',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Boutons rapides
                  const Text(
                    'Enregistrer une consommation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildQuickButton('1 verre', 250, Icons.water_drop),
                      _buildQuickButton('2 verres', 500, Icons.water_drop),
                      _buildQuickButton('1 bouteille', 500, Icons.local_drink),
                      _buildQuickButton('Autre', null, Icons.edit),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Historique du jour
                  const Text(
                    'Historique du jour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _todayEntries.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'Aucune consommation enregistrée aujourd\'hui',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _todayEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _todayEntries[index];
                            final time = entry.time;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.water_drop, color: Colors.cyan),
                                title: Text('${entry.amount} ml'),
                                subtitle: Text(
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Supprimer'),
                                        content: const Text('Supprimer cette entrée ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Annuler'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && entry.id != null) {
                                      await _hydrationService.deleteHydrationEntry(entry.id!);
                                      _loadData();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickButton(String label, int? amount, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        if (amount != null) {
          _markAsDrank(amount);
        } else {
          // Ouvrir dialog pour saisie manuelle
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quantité'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Quantité (ml)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = int.tryParse(controller.text);
                    if (amount != null && amount > 0) {
                      Navigator.pop(context);
                      _markAsDrank(amount);
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          );
        }
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan[100],
        foregroundColor: Colors.cyan[900],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}


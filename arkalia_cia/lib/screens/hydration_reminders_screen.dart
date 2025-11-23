import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/hydration_tracking.dart';
import '../services/hydration_service.dart';

/// Écran de gestion des rappels d'hydratation avec design moderne et fonctionnalités intelligentes
class HydrationRemindersScreen extends StatefulWidget {
  const HydrationRemindersScreen({super.key});

  @override
  State<HydrationRemindersScreen> createState() => _HydrationRemindersScreenState();
}

class _HydrationRemindersScreenState extends State<HydrationRemindersScreen>
    with TickerProviderStateMixin {
  final HydrationService _hydrationService = HydrationService();
  Map<String, dynamic>? _dailyProgress;
  List<HydrationEntry> _todayEntries = [];
  HydrationGoal? _goal;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _progressAnimation;
  Map<String, dynamic>? _weeklyStats;
  String? _smartSuggestion;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    );
    _loadData();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
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
        // Charger les statistiques hebdomadaires pour les suggestions intelligentes
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final stats = await _hydrationService.getStatistics(weekAgo, now);
        
        setState(() {
          _dailyProgress = progress;
          _todayEntries = entries;
          _goal = goal;
          _weeklyStats = stats;
          _isLoading = false;
        });
        
        // Générer suggestion intelligente
        _generateSmartSuggestion(progress, stats);
        
        // Animer la progression
        _progressAnimationController.forward(from: 0);
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

  void _generateSmartSuggestion(Map<String, dynamic> progress, Map<String, dynamic> stats) {
    final now = DateTime.now();
    final hour = now.hour;
    final total = progress['total'] as int? ?? 0;
    final goal = progress['goal'] as int? ?? 2000;
    final percentage = progress['percentage'] as int? ?? 0;
    final averageDaily = stats['average_daily'] as int? ?? 0;
    
    String suggestion;
    
    if (percentage >= 100) {
      suggestion = '🎉 Excellent ! Vous avez atteint votre objectif aujourd\'hui !';
    } else if (hour < 10 && total < goal * 0.2) {
      suggestion = '☀️ Bon matin ! Commencez votre journée avec un verre d\'eau.';
    } else if (hour >= 10 && hour < 14 && total < goal * 0.4) {
      suggestion = '💧 Pensez à boire régulièrement avant le déjeuner.';
    } else if (hour >= 14 && hour < 18 && total < goal * 0.6) {
      suggestion = '⏰ Après-midi : continuez à vous hydrater régulièrement.';
    } else if (hour >= 18 && total < goal * 0.8) {
      suggestion = '🌙 Il est temps de compléter votre hydratation quotidienne.';
    } else if (averageDaily > 0 && total < averageDaily * 0.7) {
      suggestion = '📊 Vous êtes en dessous de votre moyenne habituelle.';
    } else {
      final remaining = goal - total;
      final glassesNeeded = (remaining / 250).ceil();
      suggestion = '💡 Il vous reste environ $glassesNeeded verre${glassesNeeded > 1 ? 's' : ''} à boire aujourd\'hui.';
    }
    
    setState(() {
      _smartSuggestion = suggestion;
    });
  }

  Future<void> _markAsDrank(int amount) async {
    try {
      await _hydrationService.markAsDrank(amount);
      _loadData();
      if (mounted) {
        // Animation de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('$amount ml enregistrés'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
    
    // Récupérer les données quotidiennes pour le graphique
    final dailyData = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final progress = await _hydrationService.getDailyProgress(date);
      dailyData.add({
        'date': date,
        'amount': progress['total'] as int? ?? 0,
        'goal': progress['goal'] as int? ?? 2000,
      });
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📊 Statistiques de la semaine',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Graphique en barres
                  _buildWeeklyChart(dailyData),
                  const SizedBox(height: 24),
                  // Statistiques détaillées
                  _buildStatCard('Total bu', '${stats['total_amount']} ml', Icons.water_drop),
                  const SizedBox(height: 12),
                  _buildStatCard('Moyenne quotidienne', '${stats['average_daily']} ml', Icons.trending_up),
                  const SizedBox(height: 12),
                  _buildStatCard('Jours objectif atteint', '${stats['days_goal_reached']}/7', Icons.check_circle),
                  const SizedBox(height: 12),
                  _buildStatCard('Taux de conformité', '${stats['compliance_rate']}%', Icons.analytics),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: stats['compliance_rate'] / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> dailyData) {
    final maxAmount = dailyData.map((d) => d['goal'] as int).reduce(math.max);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: dailyData.asMap().entries.map((entry) {
          final data = entry.value;
          final amount = data['amount'] as int;
          final date = data['date'] as DateTime;
          final height = maxAmount > 0 ? (amount / maxAmount) : 0.0;
          final isToday = date.day == DateTime.now().day;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${amount}ml',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isToday
                              ? [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                ]
                              : [
                                  Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: height,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.water_drop,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Rappels Hydratation'),
          ],
        ),
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
                  // Suggestion intelligente
                  if (_smartSuggestion != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _smartSuggestion!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Sélecteur de date amélioré
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: const Text('Date sélectionnée'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: theme.colorScheme.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
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


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'documents_screen.dart';
import 'reminders_screen.dart';
import 'emergency_screen.dart';
import 'health_screen.dart';
import 'aria_screen.dart';
import 'sync_screen.dart';
import 'settings_screen.dart';
import 'doctors_list_screen.dart';
import 'advanced_search_screen.dart';
import 'family_sharing_screen.dart';
import 'conversational_ai_screen.dart';
import 'patterns_dashboard_screen.dart';
import 'bbia_integration_screen.dart';
import 'pathology_list_screen.dart';
import 'calendar_screen.dart';
import 'hydration_reminders_screen.dart';
import '../services/local_storage_service.dart';
import '../services/calendar_service.dart';
import '../services/search_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _documentCount = 0;
  int _upcomingRemindersCount = 0;
  bool _isLoadingStats = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, List<Map<String, dynamic>>> _searchResults = {};
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Annuler le timer précédent s'il existe
    _debounceTimer?.cancel();
    
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = {};
        });
      }
      return;
    }

    // Créer un nouveau timer avec un délai de 500ms pour la recherche globale
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    
    setState(() {
      _isSearching = true;
    });

    final results = await SearchService.searchAll(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final documents = await LocalStorageService.getDocuments();
      final reminders = await CalendarService.getUpcomingReminders();
      if (mounted) {
        setState(() {
          _documentCount = documents.length;
          _upcomingRemindersCount = reminders.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkalia CIA'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Barre de recherche globale
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Barre de recherche globale',
                    hint: 'Rechercher dans tous les modules',
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher dans documents, rappels, contacts...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.tune),
                  tooltip: 'Recherche avancée',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvancedSearchScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Résultats de recherche ou contenu normal
            if (_searchController.text.trim().isNotEmpty)
              Expanded(
                child: _buildSearchResults(),
              )
            else ...[
              // Titre principal
              Text(
                'Assistant Santé Personnel',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Votre santé au quotidien',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              // Widgets informatifs
              if (!_isLoadingStats) _buildStatsWidgets(),
              const SizedBox(height: 24),

              // 7 boutons principaux (ajout Stats)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Bouton 1: Import/voir doc
                    _buildActionButton(
                      context,
                      icon: MdiIcons.fileDocumentOutline,
                      title: 'Documents',
                      subtitle: 'Import/voir docs',
                      color: Colors.green,
                      onTap: () => _showDocuments(context),
                    ),

                    // Bouton 2: Portails santé
                    _buildActionButton(
                      context,
                      icon: MdiIcons.medicalBag,
                      title: 'Santé',
                      subtitle: 'Portails santé',
                      color: Colors.red,
                      onTap: () => _showHealth(context),
                    ),

                    // Bouton 2b: Pathologies
                    _buildActionButton(
                      context,
                      icon: MdiIcons.medicalBag,
                      title: 'Pathologies',
                      subtitle: 'Suivi pathologies',
                      color: Colors.purple,
                      onTap: () => _showPathologies(context),
                    ),

                    // Bouton 3: Rappels simples
                    _buildActionButton(
                      context,
                      icon: MdiIcons.bellOutline,
                      title: 'Rappels',
                      subtitle: 'Rappels simples',
                      color: Colors.orange,
                      onTap: () => _showReminders(context),
                    ),

                    // Bouton 4: Urgence ICE
                    _buildActionButton(
                      context,
                      icon: MdiIcons.phoneAlert,
                      title: 'Urgence',
                      subtitle: 'ICE - Contacts',
                      color: Colors.purple,
                      onTap: () => _showEmergency(context),
                    ),

                    // Bouton 5: ARIA - Laboratoire Santé
                    _buildActionButton(
                      context,
                      icon: MdiIcons.heartPulse,
                      title: 'ARIA',
                      subtitle: 'Laboratoire Santé',
                      color: Colors.red,
                      onTap: () => _showARIA(context),
                    ),

                    // Bouton 6: CIA Sync
                    _buildActionButton(
                      context,
                      icon: MdiIcons.syncIcon,
                      title: 'Sync',
                      subtitle: 'CIA ↔ ARIA',
                      color: Colors.orange,
                      onTap: () => _showSync(context),
                    ),

                    // Bouton 7: Médecins
                    _buildActionButton(
                      context,
                      icon: MdiIcons.doctor,
                      title: 'Médecins',
                      subtitle: 'Historique médecins',
                      color: Colors.teal,
                      onTap: () => _showDoctors(context),
                    ),

                    // Bouton Calendrier
                    _buildActionButton(
                      context,
                      icon: MdiIcons.calendar,
                      title: 'Calendrier',
                      subtitle: 'RDV et rappels',
                      color: Colors.blue,
                      onTap: () => _showCalendar(context),
                    ),

                    // Bouton 8: Partage Familial
                    _buildActionButton(
                      context,
                      icon: MdiIcons.accountGroup,
                      title: 'Partage',
                      subtitle: 'Partage familial',
                      color: Colors.purple,
                      onTap: () => _showFamilySharing(context),
                    ),

                    // Bouton 9: Assistant IA
                    _buildActionButton(
                      context,
                      icon: MdiIcons.robot,
                      title: 'Assistant IA',
                      subtitle: 'Posez vos questions',
                      color: Colors.teal,
                      onTap: () => _showConversationalAI(context),
                    ),

                    // Bouton 11: BBIA Robot
                    _buildActionButton(
                      context,
                      icon: MdiIcons.robot,
                      title: 'BBIA Robot',
                      subtitle: 'Intégration robotique',
                      color: Colors.deepPurple,
                      onTap: () => _showBBIAIntegration(context),
                    ),

                    // Bouton 10: Patterns IA
                    _buildActionButton(
                      context,
                      icon: MdiIcons.chartLine,
                      title: 'Patterns',
                      subtitle: 'Analyse patterns',
                      color: Colors.indigo,
                      onTap: () => _showPatterns(context),
                    ),

                    // Bouton 11: Hydratation
                    _buildActionButton(
                      context,
                      icon: MdiIcons.water,
                      title: 'Hydratation',
                      subtitle: 'Rappels hydratation',
                      color: Colors.cyan,
                      onTap: () => _showHydration(context),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Adapter les couleurs pour le mode sombre (moins saturées)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adaptedColor = isDark ? _getDarkModeColor(color) : color;
    final subtitleColor = isDark 
        ? Theme.of(context).colorScheme.onSurfaceVariant 
        : Colors.grey[600];
    
    return Semantics(
      label: '$title - $subtitle',
      button: true,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: adaptedColor,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Adapte les couleurs pour le mode sombre (moins saturées et plus douces)
  Color _getDarkModeColor(Color originalColor) {
    // Réduire la saturation et augmenter légèrement la luminosité
    // pour des couleurs plus douces en mode sombre
    final hsl = HSLColor.fromColor(originalColor);
    return hsl
        .withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0)) // Réduire saturation de 30%
        .withLightness((hsl.lightness * 1.2).clamp(0.0, 0.9)) // Augmenter luminosité de 20%
        .toColor();
  }

  void _showDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DocumentsScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showHealth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthScreen()),
    );
  }

  void _showReminders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RemindersScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showDoctors(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorsListScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarScreen()),
    );
  }

  void _showFamilySharing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FamilySharingScreen()),
    );
  }

  void _showConversationalAI(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConversationalAIScreen()),
    );
  }

  void _showPatterns(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatternsDashboardScreen()),
    );
  }

  void _showBBIAIntegration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BBIAIntegrationScreen()),
    );
  }

  void _showEmergency(BuildContext context) {
    // Navigation directe sans délai
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyScreen()),
    );
  }

  void _showARIA(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ARIAScreen()),
    );
  }

  void _showSync(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SyncScreen()),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showPathologies(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PathologyListScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showHydration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HydrationRemindersScreen()),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalResults = (_searchResults['documents']?.length ?? 0) +
        (_searchResults['reminders']?.length ?? 0) +
        (_searchResults['contacts']?.length ?? 0);

    if (totalResults == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (_searchResults['documents']?.isNotEmpty == true) ...[
          _buildSearchSection('Documents', Icons.description, Colors.green, _searchResults['documents']!),
        ],
        if (_searchResults['reminders']?.isNotEmpty == true) ...[
          _buildSearchSection('Rappels', Icons.notifications, Colors.orange, _searchResults['reminders']!),
        ],
        if (_searchResults['contacts']?.isNotEmpty == true) ...[
          _buildSearchSection('Contacts', Icons.contacts, Colors.red, _searchResults['contacts']!),
        ],
      ],
    );
  }

  Widget _buildSearchSection(String title, IconData icon, Color color, List<Map<String, dynamic>> items) {
    return Semantics(
      label: 'Section $title avec ${items.length} résultat(s)',
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    '$title (${items.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...items.take(5).map((item) => Semantics(
                  label: '${item['title'] ?? item['name'] ?? item['original_name'] ?? 'Sans titre'}',
                  button: true,
                  child: ListTile(
                    title: Text(item['title'] ?? item['name'] ?? item['original_name'] ?? 'Sans titre'),
                    subtitle: Text(item['description'] ?? item['phone'] ?? item['category'] ?? ''),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // Navigation vers le détail selon le type
                      if (title == 'Documents') {
                        _showDocuments(context);
                      } else if (title == 'Rappels') {
                        _showReminders(context);
                      } else if (title == 'Contacts') {
                        _showEmergency(context);
                      }
                    },
                  ),
                )),
            if (items.length > 5)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '... et ${items.length - 5} autre(s)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsWidgets() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            color: isDark 
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Icon(
                    Icons.folder, 
                    color: isDark ? Colors.green[300] : Colors.green[700], 
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_documentCount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green[300] : Colors.green[700],
                    ),
                  ),
                  Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 2,
            color: isDark 
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications, 
                    color: isDark ? Colors.orange[300] : Colors.orange[700], 
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_upcomingRemindersCount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.orange[300] : Colors.orange[700],
                    ),
                  ),
                  Text(
                    'Rappels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

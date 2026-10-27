import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'pathology_list_screen.dart';
import 'calendar_screen.dart';
import 'hydration_reminders_screen.dart';
import 'stats_screen.dart';
import '../services/local_storage_service.dart';
import '../services/calendar_service.dart';
import '../services/search_service.dart';
import '../utils/input_sanitizer.dart';
import '../utils/page_transitions.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les stats quand la page devient visible (après retour de navigation)
    // Utiliser un petit délai pour éviter les appels multiples
    Future.microtask(() {
      if (mounted) {
        _loadStats();
      }
    });
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

    // Sanitizer la requête de recherche pour prévenir XSS
    final sanitizedQuery = InputSanitizer.sanitizeForStorage(query);

    setState(() {
      _isSearching = true;
    });

    final results = await SearchService.searchAll(sanitizedQuery);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _loadStats() async {
    // Charger les stats rapidement sans bloquer l'affichage
    try {
      // Charger les documents en premier (rapide)
      final documents = await LocalStorageService.getDocuments();

      // Compter les rappels locaux (rapide)
      final localReminders = await LocalStorageService.getReminders();

      // Mettre à jour immédiatement avec les données locales
      if (mounted) {
        setState(() {
          _documentCount = documents.length;
          _upcomingRemindersCount = localReminders.length;
          _isLoadingStats =
              false; // Afficher les stats même si le calendrier n'est pas encore chargé
        });
      }

      // Charger le calendrier en arrière-plan (seulement sur mobile, avec timeout court)
      if (!kIsWeb && mounted) {
        try {
          final calendarReminders = await CalendarService.getUpcomingReminders()
              .timeout(
                const Duration(seconds: 1),
                onTimeout: () => <Map<String, dynamic>>[],
              );

          if (mounted) {
            setState(() {
              _upcomingRemindersCount =
                  localReminders.length + calendarReminders.length;
            });
          }
        } catch (e) {
          // Ignorer les erreurs de calendrier, on garde les rappels locaux
        }
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
        title: Semantics(
          label: 'Arkalia CIA - Assistant Santé Personnel',
          header: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Logo Arkalia CIA',
                image: true,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback si l'image ne se charge pas
                    return const Icon(Icons.health_and_safety, size: 32);
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Text('Arkalia CIA'),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          Semantics(
            label: 'Paramètres',
            hint: 'Ouvre les paramètres de l\'application',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettings(context),
              tooltip: 'Paramètres',
            ),
          ),
        ],
      ),
      body: Semantics(
        label: 'Page d\'accueil Arkalia CIA',
        hint: 'Assistant santé personnel avec recherche et modules',
        child: SingleChildScrollView(
          child: Padding(
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
                        textField: true,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Rechercher documents, rappels, contacts…',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? Semantics(
                                      label: 'Effacer la recherche',
                                      hint: 'Supprime le texte de recherche',
                                      button: true,
                                      child: IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                        tooltip: 'Effacer',
                                      ),
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
                    Semantics(
                      label: 'Recherche avancée',
                      hint: 'Ouvre les options de recherche avancée',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.tune),
                        tooltip: 'Recherche avancée',
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransitions.slideRight(
                              const AdvancedSearchScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Résultats de recherche ou contenu normal
                if (_searchController.text.trim().isNotEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _buildSearchResults(),
                  )
                else ...[
                  // Titre principal avec accessibilité
                  Semantics(
                    header: true,
                    child: Text(
                      'Assistant Santé Personnel',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Sous-titre: Votre santé au quotidien',
                    child: Text(
                      'Votre santé, au quotidien',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingStats)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    _buildStatsWidgets(),
                  const SizedBox(height: 24),
                  _buildPrimaryModules(context),
                  const SizedBox(height: 8),
                  _buildMoreModules(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Six actions quotidiennes prioritaires.
  Widget _buildPrimaryModules(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Modules principaux',
      hint: 'Accès rapide aux fonctions essentielles',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accès rapide',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.92,
            children: [
              _buildActionButton(
                context,
                icon: MdiIcons.fileDocumentOutline,
                title: 'Documents',
                subtitle: 'Importer et consulter',
                color: scheme.primary,
                onTap: () => _showDocuments(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.medicalBag,
                title: 'Santé',
                subtitle: 'Portails médicaux',
                color: scheme.tertiary,
                onTap: () => _showHealth(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.bellOutline,
                title: 'Rappels',
                subtitle: 'Médicaments et RDV',
                color: scheme.secondary,
                onTap: () => _showReminders(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.phoneAlert,
                title: 'Urgence',
                subtitle: 'Contacts ICE',
                color: scheme.error,
                onTap: () => _showEmergency(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.calendar,
                title: 'Calendrier',
                subtitle: 'Agenda santé',
                color: scheme.primary,
                onTap: () => _showCalendar(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.heartPulse,
                title: 'ARIA',
                subtitle: 'Douleur et patterns',
                color: scheme.tertiary,
                onTap: () => _showARIA(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Modules secondaires — tous restent accessibles.
  Widget _buildMoreModules(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          'Plus',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Médecins, pathologies, sync et outils',
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.92,
            children: [
              _buildActionButton(
                context,
                icon: MdiIcons.doctor,
                title: 'Médecins',
                subtitle: 'Carnet de contacts',
                color: scheme.secondary,
                onTap: () => _showDoctors(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.medicalBag,
                title: 'Pathologies',
                subtitle: 'Suivi personnalisé',
                color: scheme.tertiary,
                onTap: () => _showPathologies(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.syncIcon,
                title: 'Sync',
                subtitle: 'CIA et ARIA',
                color: scheme.primary,
                onTap: () => _showSync(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.accountGroup,
                title: 'Partage',
                subtitle: 'Partage familial',
                color: scheme.secondary,
                onTap: () => _showFamilySharing(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.robot,
                title: 'Assistant',
                subtitle: 'Questions santé',
                color: scheme.tertiary,
                onTap: () => _showConversationalAI(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.chartLine,
                title: 'Patterns',
                subtitle: 'Analyses',
                color: scheme.primary,
                onTap: () => _showPatterns(context),
              ),
              _buildActionButton(
                context,
                icon: MdiIcons.water,
                title: 'Hydratation',
                subtitle: 'Objectifs quotidiens',
                color: scheme.secondary,
                onTap: () => _showHydration(context),
              ),
            ],
          ),
        ],
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
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: '$title - $subtitle',
      button: true,
      child: Tooltip(
        message: '$title : $subtitle',
        preferBelow: false,
        child: Card(
          elevation: 2,
          color: scheme.surfaceContainerLow,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  void _showDocuments(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const DocumentsScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showHealth(BuildContext context) {
    Navigator.push(context, PageTransitions.slideRight(const HealthScreen()));
  }

  void _showReminders(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const RemindersScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showDoctors(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const DoctorsListScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showCalendar(BuildContext context) {
    Navigator.push(context, PageTransitions.slideRight(const CalendarScreen()));
  }

  void _showFamilySharing(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const FamilySharingScreen()),
    );
  }

  void _showConversationalAI(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const ConversationalAIScreen()),
    );
  }

  void _showPatterns(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const PatternsDashboardScreen()),
    );
  }

  void _showEmergency(BuildContext context) {
    // Navigation directe sans délai
    if (!mounted) return;
    Navigator.push(
      context,
      PageTransitions.slideRight(const EmergencyScreen()),
    );
  }

  void _showARIA(BuildContext context) {
    Navigator.push(context, PageTransitions.slideRight(const ARIAScreen()));
  }

  void _showSync(BuildContext context) {
    Navigator.push(context, PageTransitions.slideRight(const SyncScreen()));
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const SettingsScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showPathologies(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const PathologyListScreen()),
    ).then((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  void _showHydration(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(const HydrationRemindersScreen()),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalResults =
        (_searchResults['documents']?.length ?? 0) +
        (_searchResults['reminders']?.length ?? 0) +
        (_searchResults['contacts']?.length ?? 0);

    final scheme = Theme.of(context).colorScheme;

    if (totalResults == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(color: scheme.onSurface, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Modifiez votre recherche et réessayez.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (_searchResults['documents']?.isNotEmpty == true) ...[
          _buildSearchSection(
            'Documents',
            Icons.description,
            scheme.primary,
            _searchResults['documents']!,
          ),
        ],
        if (_searchResults['reminders']?.isNotEmpty == true) ...[
          _buildSearchSection(
            'Rappels',
            Icons.notifications,
            scheme.secondary,
            _searchResults['reminders']!,
          ),
        ],
        if (_searchResults['contacts']?.isNotEmpty == true) ...[
          _buildSearchSection(
            'Contacts',
            Icons.contacts,
            scheme.error,
            _searchResults['contacts']!,
          ),
        ],
      ],
    );
  }

  Widget _buildSearchSection(
    String title,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> items,
  ) {
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...items
                .take(5)
                .map(
                  (item) => Semantics(
                    label:
                        '${item['title'] ?? item['name'] ?? item['original_name'] ?? 'Sans titre'}',
                    button: true,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        item['title'] ??
                            item['name'] ??
                            item['original_name'] ??
                            'Sans titre',
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item['description'] ??
                              item['phone'] ??
                              item['category'] ??
                              '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
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
                  ),
                ),
            if (items.length > 5)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '… et ${items.length - 5} autre(s)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsWidgets() {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: 'Documents',
            button: true,
            child: InkWell(
              onTap: () => _showDocuments(context),
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 2,
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Icon(Icons.folder, color: scheme.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '$_documentCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            label: 'Statistiques rappels',
            button: true,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 2,
                color: scheme.secondaryContainer.withValues(alpha: 0.45),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: scheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_upcomingRemindersCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scheme.secondary,
                        ),
                      ),
                      Text(
                        'Rappels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

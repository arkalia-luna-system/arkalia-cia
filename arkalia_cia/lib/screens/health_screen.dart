import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/backend_config_service.dart';
import '../services/health_portal_favorites_service.dart';
import '../utils/validation_helper.dart';
import '../config/health_portals_config.dart';
import 'medical_report_screen.dart';
import '../utils/error_helper.dart';
import '../widgets/senior_empty_state.dart';

/// Vue typée d’un portail santé (UI) — sans réécriture du storage / API Map.
class _HealthPortal {
  const _HealthPortal({
    required this.name,
    required this.url,
    this.description,
    this.category,
  });

  final String name;
  final String url;
  final String? description;
  final String? category;

  factory _HealthPortal.fromMap(Map<String, dynamic> map) {
    return _HealthPortal(
      name: map['name'] as String? ?? 'Portail',
      url: map['url'] as String? ?? '',
      description: map['description'] as String?,
      category: map['category'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'url': url,
    if (description != null) 'description': description,
    if (category != null) 'category': category,
  };
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<_HealthPortal> portals = [];
  bool isLoading = false;
  bool _showFavoritesOnly = false;
  Set<String> _favoriteUrls = {};

  @override
  void initState() {
    super.initState();
    // Charger les portails (backend + pré-configurés)
    _loadPortals();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await HealthPortalFavoritesService.getFavoriteUrls();
    if (mounted) {
      setState(() {
        _favoriteUrls = favorites;
      });
    }
  }

  Future<void> _loadPortals() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    // Toujours afficher les portails pré-configurés
    final belgianPortals =
        BelgianHealthPortals.getPortalsAsMaps()
            .map(_HealthPortal.fromMap)
            .toList();
    final Set<String> existingUrls = {};
    List<_HealthPortal> allPortals = [];

    try {
      // Essayer de charger depuis le backend si disponible
      final backendEnabled = await BackendConfigService.isBackendEnabled();
      if (backendEnabled) {
        try {
          final backendPortals = await ApiService.getHealthPortals();
          final typedBackend =
              backendPortals.map(_HealthPortal.fromMap).toList();
          existingUrls.addAll(typedBackend.map((p) => p.url));
          allPortals.addAll(typedBackend);

          // Ajouter les portails pré-configurés qui ne sont pas déjà dans le backend
          for (final portal in belgianPortals) {
            if (!existingUrls.contains(portal.url)) {
              // Essayer d'ajouter au backend (silencieusement)
              try {
                final result = await ApiService.createHealthPortal(
                  name: portal.name,
                  url: portal.url,
                  description: portal.description ?? '',
                  category: portal.category ?? '',
                );

                if (result['success'] != false &&
                    result['backend_unavailable'] != true &&
                    result['backend_disabled'] != true) {
                  allPortals.add(portal);
                } else {
                  allPortals.add(portal);
                }
              } catch (e) {
                allPortals.add(portal);
              }
            }
          }
        } catch (e) {
          allPortals = List.from(belgianPortals);
        }
      } else {
        allPortals = List.from(belgianPortals);
      }
    } catch (e) {
      allPortals = List.from(belgianPortals);
    }

    if (mounted) {
      setState(() {
        portals = allPortals;
        isLoading = false;
      });
    }
  }

  Future<void> _showAddPortalDialog() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();

    final result = await showDialog<_HealthPortal>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Nouveau portail santé'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du portail',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            labelText: 'URL du portail',
                            border: const OutlineInputBorder(),
                            hintText: 'https://exemple.com',
                            helperText:
                                'Doit commencer par http:// ou https://',
                            errorText:
                                urlController.text.isNotEmpty &&
                                        !ValidationHelper.isValidUrl(
                                          urlController.text.trim(),
                                        )
                                    ? 'URL invalide'
                                    : null,
                          ),
                          keyboardType: TextInputType.url,
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optionnel)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie (optionnel)',
                            border: OutlineInputBorder(),
                            hintText: 'ex: Médecin, Pharmacie, Hôpital',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            ValidationHelper.isValidUrl(
                              urlController.text.trim(),
                            )) {
                          Navigator.pop(
                            context,
                            _HealthPortal(
                              name: nameController.text,
                              url: urlController.text.trim(),
                              description: descriptionController.text,
                              category: categoryController.text,
                            ),
                          );
                        }
                      },
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
          ),
    );

    if (result != null) {
      await _createPortal(result);
    }
  }

  Future<void> _createPortal(_HealthPortal portalData) async {
    try {
      Map<String, dynamic> response = await ApiService.createHealthPortal(
        name: portalData.name,
        url: portalData.url,
        description: portalData.description,
        category: portalData.category,
      );

      if (response['success'] != false) {
        _showSuccess('Portail ajouté avec succès !');
        _loadPortals();
      } else {
        ErrorHelper.logError('HealthScreen.create', response['error']);
        _showError(ErrorHelper.getUserFriendlyMessage(response['error']));
      }
    } catch (e) {
      ErrorHelper.logError('HealthScreen', e);
      _showError(ErrorHelper.getUserFriendlyMessage(e));
    }
  }

  Future<void> _openPortal(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Impossible d\'ouvrir l\'URL');
      }
    } catch (e) {
      ErrorHelper.logError('HealthScreen._openPortal', e);
      _showError(ErrorHelper.getUserFriendlyMessage(e));
    }
  }

  void _showSuccess(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: scheme.primary),
    );
  }

  void _showError(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: scheme.error),
    );
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.medical_services;

    final cat = category.toLowerCase();
    if (cat.contains('médecin') || cat.contains('docteur')) {
      return Icons.person;
    } else if (cat.contains('pharmacie')) {
      return Icons.local_pharmacy;
    } else if (cat.contains('hôpital') || cat.contains('hopital')) {
      return Icons.local_hospital;
    } else if (cat.contains('urgence')) {
      return Icons.emergency;
    } else {
      return Icons.medical_services;
    }
  }

  /// Couleurs sémantiques de catégorie (données) — volontairement distinctes du chrome UI.
  Color _getCategoryColor(String? category) {
    if (category == null) return Colors.red;

    final cat = category.toLowerCase();
    if (cat.contains('médecin') || cat.contains('docteur')) {
      return Colors.blue;
    } else if (cat.contains('pharmacie')) {
      return Colors.green;
    } else if (cat.contains('hôpital') || cat.contains('hopital')) {
      return Colors.red;
    } else if (cat.contains('urgence')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  List<_HealthPortal> _getFilteredPortals() {
    if (_showFavoritesOnly) {
      return portals.where((portal) {
        return _favoriteUrls.contains(portal.url);
      }).toList();
    }
    return portals;
  }

  Widget _buildPortalsList() {
    final filteredPortals = _getFilteredPortals();
    final scheme = Theme.of(context).colorScheme;

    if (_showFavoritesOnly && filteredPortals.isEmpty) {
      return const SeniorEmptyState(
        icon: Icons.star_border,
        title: 'Aucun portail favori',
        message: 'Épinglez des portails pour les retrouver facilement.',
      );
    }

    return ListView.builder(
      itemCount: filteredPortals.length,
      itemBuilder: (context, index) {
        final portal = filteredPortals[index];
        final category = portal.category;
        final icon = _getCategoryIcon(category);
        final color = _getCategoryColor(category);
        final url = portal.url;
        final isFavorite = _favoriteUrls.contains(url);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            onTap: () => _openPortal(url),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: scheme.surfaceContainerHighest,
                radius: 24,
                child: Icon(icon, color: color, size: 28),
              ),
              title: Text(
                portal.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (portal.description != null &&
                        portal.description!.isNotEmpty)
                      Text(
                        portal.description!,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    if (category != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    button: true,
                    label:
                        isFavorite
                            ? 'Retirer ${portal.name} des favoris'
                            : 'Ajouter ${portal.name} aux favoris',
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color:
                            isFavorite ? Colors.amber : scheme.onSurfaceVariant,
                        size: 24,
                      ),
                      onPressed: () async {
                        await HealthPortalFavoritesService.toggleFavorite(url);
                        await _loadFavorites();
                      },
                      tooltip:
                          isFavorite
                              ? 'Retirer des favoris'
                              : 'Ajouter aux favoris',
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Ouvrir le portail ${portal.name}',
                    child: IconButton(
                      icon: Icon(
                        Icons.open_in_new,
                        color: scheme.primary,
                        size: 24,
                      ),
                      onPressed: () => _openPortal(url),
                      tooltip: 'Ouvrir le portail',
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portails Santé'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
            tooltip:
                _showFavoritesOnly
                    ? 'Afficher tous les portails'
                    : 'Afficher seulement les favoris',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          IconButton(
            icon: const Icon(Icons.description, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalReportScreen(),
                ),
              );
            },
            tooltip: 'Générer rapport médical',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () {
              _loadPortals();
              _loadFavorites();
            },
            tooltip: 'Actualiser',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : portals.isEmpty
              ? const SeniorEmptyState(
                icon: Icons.medical_services,
                title: 'Aucun portail santé',
                message: 'Appuyez sur + pour ajouter un portail.',
              )
              : _buildPortalsList(),
      floatingActionButton: Semantics(
        button: true,
        label: 'Ajouter un portail santé',
        child: FloatingActionButton(
          onPressed: _showAddPortalDialog,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          tooltip: 'Ajouter un portail santé',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

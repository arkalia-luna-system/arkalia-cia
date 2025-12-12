import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/backend_config_service.dart';
import '../services/health_portal_favorites_service.dart';
import '../utils/validation_helper.dart';
import '../config/health_portals_config.dart';
import 'medical_report_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<Map<String, dynamic>> portals = [];
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
    final belgianPortals = BelgianHealthPortals.getPortalsAsMaps();
    final Set<String> existingUrls = {};
    List<Map<String, dynamic>> allPortals = [];

    try {
      // Essayer de charger depuis le backend si disponible
      final backendEnabled = await BackendConfigService.isBackendEnabled();
      if (backendEnabled) {
        try {
          final backendPortals = await ApiService.getHealthPortals();
          existingUrls.addAll(backendPortals.map((p) => p['url'] as String));
          allPortals.addAll(backendPortals);
          
          // Ajouter les portails pré-configurés qui ne sont pas déjà dans le backend
          for (final portal in belgianPortals) {
            if (!existingUrls.contains(portal['url'] as String)) {
              // Essayer d'ajouter au backend (silencieusement)
              try {
                final result = await ApiService.createHealthPortal(
                  name: portal['name'] as String,
                  url: portal['url'] as String,
                  description: portal['description'] as String,
                  category: portal['category'] as String,
                );
                
                if (result['success'] != false && 
                    result['backend_unavailable'] != true && 
                    result['backend_disabled'] != true) {
                  // Ajouter à la liste si créé avec succès
                  allPortals.add(portal);
                } else {
                  // Ajouter quand même à la liste pour affichage
                  allPortals.add(portal);
                }
              } catch (e) {
                // En cas d'erreur, ajouter quand même pour affichage
                allPortals.add(portal);
              }
            }
          }
        } catch (e) {
          // Si erreur backend, utiliser uniquement les portails pré-configurés
          allPortals = List.from(belgianPortals);
        }
      } else {
        // Backend désactivé, utiliser uniquement les portails pré-configurés
        allPortals = List.from(belgianPortals);
      }
    } catch (e) {
      // En cas d'erreur, utiliser les portails pré-configurés
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

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                    helperText: 'Doit commencer par http:// ou https://',
                    errorText: urlController.text.isNotEmpty && 
                        !ValidationHelper.isValidUrl(urlController.text.trim())
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
                  ValidationHelper.isValidUrl(urlController.text.trim())) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'url': urlController.text.trim(),
                  'description': descriptionController.text,
                  'category': categoryController.text,
                });
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

  Future<void> _createPortal(Map<String, dynamic> portalData) async {
    try {
      Map<String, dynamic> response = await ApiService.createHealthPortal(
        name: portalData['name'],
        url: portalData['url'],
        description: portalData['description'],
        category: portalData['category'],
      );

      if (response['success'] != false) {
        _showSuccess('Portail ajouté avec succès !');
        _loadPortals();
      } else {
        _showError('Erreur création: ${response['error']}');
      }
    } catch (e) {
      _showError('Erreur: $e');
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
      _showError('Erreur ouverture: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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

  List<Map<String, dynamic>> _getFilteredPortals() {
    if (_showFavoritesOnly) {
      return portals.where((portal) {
        final url = portal['url'] as String? ?? '';
        return _favoriteUrls.contains(url);
      }).toList();
    }
    return portals;
  }

  Widget _buildPortalsList() {
    final filteredPortals = _getFilteredPortals();
    
    if (_showFavoritesOnly && filteredPortals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun portail favori',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Épinglez des portails pour les retrouver facilement',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPortals.length,
      itemBuilder: (context, index) {
        final portal = filteredPortals[index];
        final category = portal['category'];
        final icon = _getCategoryIcon(category);
        final color = _getCategoryColor(category);
        final url = portal['url'] as String? ?? '';
        final isFavorite = _favoriteUrls.contains(url);

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: InkWell(
            onTap: () => _openPortal(url),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: 24,
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              title: Text(
                portal['name'] ?? 'Portail',
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
                    if (portal['description'] != null)
                      Text(
                        portal['description'],
                        style: const TextStyle(
                          color: Colors.grey,
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
                          color: Colors.grey.shade100,
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
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : Colors.grey,
                      size: 24,
                    ),
                    onPressed: () async {
                      await HealthPortalFavoritesService.toggleFavorite(url);
                      await _loadFavorites();
                    },
                    tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.blue, size: 24),
                    onPressed: () => _openPortal(url),
                    tooltip: 'Ouvrir le portail',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portails Santé'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
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
            tooltip: _showFavoritesOnly ? 'Afficher tous les portails' : 'Afficher seulement les favoris',
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
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
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () {
              _loadPortals();
              _loadFavorites();
            },
            tooltip: 'Actualiser',
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : portals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 64,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun portail santé',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Appuyez sur + pour ajouter un portail',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildPortalsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPortalDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

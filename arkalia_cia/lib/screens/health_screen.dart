import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/validation_helper.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<Map<String, dynamic>> portals = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPortals();
    _addBelgianPortals();
  }

  Future<void> _addBelgianPortals() async {
    // Ajouter les portails santé belges pré-configurés si pas déjà présents
    const belgianPortals = [
      {
        'name': 'eHealth',
        'url': 'https://www.ehealth.fgov.be',
        'description': 'Plateforme eHealth belge - Accès sécurisé aux données de santé',
        'category': 'Administration',
      },
      {
        'name': 'Inami',
        'url': 'https://www.inami.fgov.be',
        'description': 'Institut national d\'assurance maladie-invalidité',
        'category': 'Administration',
      },
      {
        'name': 'Sciensano',
        'url': 'https://www.sciensano.be',
        'description': 'Institut scientifique de santé publique',
        'category': 'Information',
      },
      {
        'name': 'SPF Santé Publique',
        'url': 'https://www.health.belgium.be',
        'description': 'Service public fédéral Santé publique',
        'category': 'Administration',
      },
    ];
    
    // Vérifier et ajouter les portails s'ils n'existent pas déjà
    try {
      final existingPortals = await ApiService.getHealthPortals();
      final existingUrls = existingPortals.map((p) => p['url'] as String).toSet();
      
      for (final portal in belgianPortals) {
        if (!existingUrls.contains(portal['url'] as String)) {
          try {
            await ApiService.createHealthPortal(
              name: portal['name'] as String,
              url: portal['url'] as String,
              description: portal['description'] as String,
              category: portal['category'] as String,
            );
          } catch (e) {
            // Ignorer les erreurs si le portail existe déjà ou si le backend n'est pas disponible
          }
        }
      }
    } catch (e) {
      // Si le backend n'est pas disponible, ignorer silencieusement
      // Les portails seront ajoutés lors de la prochaine connexion
    }
  }

  Future<void> _loadPortals() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final ports = await ApiService.getHealthPortals();
      if (mounted) {
        setState(() {
          portals = ports;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showError('Erreur lors du chargement des portails: $e');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portails Santé'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPortals,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : portals.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 64,
                        color: Colors.red,
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
              : ListView.builder(
                  itemCount: portals.length,
                  itemBuilder: (context, index) {
                    final portal = portals[index];
                    final category = portal['category'];
                    final icon = _getCategoryIcon(category);
                    final color = _getCategoryColor(category);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(
                            icon,
                            color: color,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          portal['name'] ?? 'Portail',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (portal['description'] != null)
                              Text(
                                portal['description'],
                                style: const TextStyle(color: Colors.grey),
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.blue),
                          onPressed: () => _openPortal(portal['url'] ?? ''),
                        ),
                        onTap: () => _openPortal(portal['url'] ?? ''),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPortalDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

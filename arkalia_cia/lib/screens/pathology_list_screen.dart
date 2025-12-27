import 'package:flutter/material.dart';
import '../services/pathology_service.dart';
import '../models/pathology.dart';
import '../utils/input_sanitizer.dart';
import 'pathology_detail_screen.dart';

class PathologyListScreen extends StatefulWidget {
  const PathologyListScreen({super.key});

  @override
  State<PathologyListScreen> createState() => _PathologyListScreenState();
}

class _PathologyListScreenState extends State<PathologyListScreen> {
  final PathologyService _pathologyService = PathologyService();
  Map<String, List<Pathology>> _pathologiesByCategory = {};
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadPathologies();
  }

  Future<void> _loadPathologies() async {
    setState(() => _isLoading = true);
    try {
      final grouped = await _pathologyService.getPathologiesByCategory();
      if (mounted) {
        setState(() {
          _pathologiesByCategory = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement: $e')),
        );
      }
    }
  }

  Future<void> _showAddPathologyDialog() async {
    final templates = PathologyService.getAllTemplates();
    const customOption = 'Personnalisée';

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une pathologie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choisissez un template ou créez une pathologie personnalisée:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...templates.map((template) => ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: template.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(template.name),
                    onTap: () => Navigator.pop(context, template.name),
                  )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text(customOption),
                onTap: () => Navigator.pop(context, customOption),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected == null || !mounted) return;

    Pathology? newPathology;
    if (selected == customOption) {
      // Créer une pathologie personnalisée
      final nameController = TextEditingController();
      final descriptionController = TextEditingController();

      if (!mounted) return;
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nouvelle pathologie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la pathologie',
                  hintText: 'Ex: Diabète',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      );

      if (result == true && nameController.text.isNotEmpty) {
        // Sanitizer les entrées utilisateur pour prévenir XSS
        final sanitizedName = InputSanitizer.sanitizeForStorage(nameController.text.trim());
        final sanitizedDescription = descriptionController.text.trim().isNotEmpty
            ? InputSanitizer.sanitizeForStorage(descriptionController.text.trim())
            : null;
        
        newPathology = Pathology(
          name: sanitizedName,
          description: sanitizedDescription,
          color: Colors.blue,
        );
      }
    } else {
      // Utiliser le template sélectionné
      newPathology = templates.firstWhere((t) => t.name == selected);
    }

    if (newPathology != null) {
      try {
        await _pathologyService.insertPathology(newPathology);
        await _pathologyService.scheduleReminders(newPathology);
        if (mounted) {
          _loadPathologies();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pathologie ajoutée avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  Future<void> _deletePathology(Pathology pathology) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la pathologie'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${pathology.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _pathologyService.deletePathology(pathology.id!);
        if (mounted) {
          _loadPathologies();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pathologie supprimée')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  Future<void> _showFilterDialog() async {
    final categories = _pathologiesByCategory.keys.toList()..sort();
    String? tempSelected = _selectedCategory;
    final selected = await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtrer par catégorie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Toutes les catégories'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: tempSelected,
                    onChanged: (value) {
                      setState(() {
                        tempSelected = value;
                      });
                      Navigator.pop(context, value);
                    },
                  ),
                ),
                const Divider(),
                ...categories.map((category) {
                  final count = _pathologiesByCategory[category]?.length ?? 0;
                  return ListTile(
                    title: Text(category),
                    subtitle: Text('$count pathologie${count > 1 ? 's' : ''}'),
                    leading: Radio<String?>(
                      value: category,
                      groupValue: tempSelected,
                      onChanged: (value) {
                        setState(() {
                          tempSelected = value;
                        });
                        Navigator.pop(context, value);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedCategory = selected;
      });
      _loadPathologies();
    }
  }

  Widget _buildPathologiesList() {
    final categoriesToShow = _selectedCategory != null
        ? [_selectedCategory!]
        : _pathologiesByCategory.keys.toList()..sort();

    return ListView.builder(
      itemCount: categoriesToShow.length,
      itemBuilder: (context, categoryIndex) {
        final category = categoriesToShow[categoryIndex];
        final pathologies = _pathologiesByCategory[category] ?? [];

        return ExpansionTile(
          leading: Icon(
            Icons.folder,
            color: Colors.purple[600],
          ),
          title: Text(
            category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text('${pathologies.length} pathologie${pathologies.length > 1 ? 's' : ''}'),
          children: pathologies.map((pathology) {
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: pathology.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: pathology.color,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.medical_services,
                    color: pathology.color,
                    size: 24,
                  ),
                ),
                title: Text(
                  pathology.name,
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
                      if (pathology.description != null)
                        Text(
                          pathology.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      if (pathology.subcategory != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          pathology.subcategory!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePathology(pathology);
                    }
                  },
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PathologyDetailScreen(
                        pathologyId: pathology.id!,
                      ),
                    ),
                  );
                  _loadPathologies();
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathologies'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrer par catégorie',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPathologyDialog,
            tooltip: 'Ajouter une pathologie',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPathologies,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pathologiesByCategory.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.medical_services,
                                size: 64,
                                color: Colors.purple[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucune pathologie',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Appuyez sur + pour ajouter une pathologie',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _buildPathologiesList(),
      ),
    );
  }
}


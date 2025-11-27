import 'package:flutter/material.dart';
import '../services/pathology_service.dart';
import '../models/pathology.dart';
import 'pathology_detail_screen.dart';

class PathologyListScreen extends StatefulWidget {
  const PathologyListScreen({super.key});

  @override
  State<PathologyListScreen> createState() => _PathologyListScreenState();
}

class _PathologyListScreenState extends State<PathologyListScreen> {
  final PathologyService _pathologyService = PathologyService();
  List<Pathology> _pathologies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPathologies();
  }

  Future<void> _loadPathologies() async {
    setState(() => _isLoading = true);
    try {
      final pathologies = await _pathologyService.getAllPathologies();
      if (mounted) {
        setState(() {
          _pathologies = pathologies;
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
        newPathology = Pathology(
          name: nameController.text,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathologies'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPathologyDialog,
            tooltip: 'Ajouter une pathologie',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pathologies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune pathologie suivie',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Appuyez sur + pour ajouter une pathologie',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _pathologies.length,
                  itemBuilder: (context, index) {
                    final pathology = _pathologies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
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
                          ),
                        ),
                        title: Text(
                          pathology.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: pathology.description != null
                            ? Text(
                                pathology.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
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
                  },
                ),
    );
  }
}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/local_storage_service.dart';
import '../services/file_storage_service.dart';
import '../services/category_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Map<String, dynamic>> documents = [];
  List<Map<String, dynamic>> filteredDocuments = [];
  bool isLoading = false;
  bool isUploading = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _searchController.addListener(_filterDocuments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDocuments() {
    if (!mounted) return;
    
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDocuments = documents.where((doc) {
        final name = (doc['original_name'] ?? '').toLowerCase();
        final matchesSearch = name.contains(query);
        final matchesCategory = _selectedCategory == 'Tous' ||
            (doc['category'] ?? 'Non catégorisé') == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final docs = await LocalStorageService.getDocuments();
      if (!mounted) return;
      
      setState(() {
        documents = docs;
        filteredDocuments = docs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
        documents = [];
        filteredDocuments = [];
      });
      
      // Afficher l'erreur seulement si le widget est monté
      if (mounted) {
        _showError('Erreur lors du chargement des documents: $e');
      }
    }
  }

  Future<void> _uploadDocument() async {
    if (!mounted) return;
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        if (!mounted) return;
        
        setState(() {
          isUploading = true;
        });

        File sourceFile = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_$fileName';

        // Copier le fichier vers le répertoire documents dédié
        final savedFile = await FileStorageService.copyToDocumentsDirectory(
          sourceFile,
          uniqueFileName,
        );

        // Demander la catégorie avant de sauvegarder
        if (!mounted) return;
        final category = await _showCategoryDialog();
        
        // Sauvegarder les métadonnées localement
        final document = {
          'id': timestamp.toString(), // ID en String pour cohérence
          'name': uniqueFileName,
          'original_name': fileName,
          'path': savedFile.path,
          'file_size': await savedFile.length(),
          'category': category ?? 'Autre',
          'created_at': DateTime.now().toIso8601String(),
        };

        await LocalStorageService.saveDocument(document);

        if (!mounted) return;
        
        setState(() {
          isUploading = false;
        });

        _showSuccess('Document $fileName ajouté avec succès !');
        _loadDocuments(); // Recharger la liste
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isUploading = false;
      });
      _showError('Erreur sélection fichier: $e');
    }
  }


  Future<void> _deleteDocument(dynamic documentId) async {
    if (!mounted) return;
    
    // Convertir l'ID en String pour cohérence
    final docIdString = documentId.toString();
    
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce document ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Trouver le document pour obtenir le nom du fichier
        // Comparer en convertissant les deux en String
        final doc = documents.firstWhere(
          (d) => d['id'].toString() == docIdString,
          orElse: () => {},
        );
        
        if (doc.isEmpty) {
          if (mounted) {
            _showError('Document introuvable');
          }
          return;
        }
        
        final fileName = doc['name'] as String?;
        
        // Supprimer le fichier physique
        if (fileName != null) {
          await FileStorageService.deleteDocumentFile(fileName);
        }
        
        // Supprimer les métadonnées
        await LocalStorageService.deleteDocument(docIdString);
        
        if (mounted) {
          _showSuccess('Document supprimé avec succès !');
          _loadDocuments(); // Recharger la liste
        }
      } catch (e) {
        if (mounted) {
          _showError('Erreur lors de la suppression: $e');
        }
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _previewDocument(Map<String, dynamic> doc) async {
    if (!mounted) return;
    
    try {
      final filePath = doc['path'] as String?;
      if (filePath == null || filePath.isEmpty) {
        _showError('Chemin du fichier introuvable');
        return;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        _showError('Le fichier n\'existe plus');
        // Retirer le document de la liste s'il n'existe plus
        final docId = doc['id'];
        if (docId != null) {
          await LocalStorageService.deleteDocument(docId.toString());
          if (mounted) {
            _loadDocuments();
          }
        }
        return;
      }

      // Ouvrir le PDF avec une application externe
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Impossible d\'ouvrir le PDF. Installez une application de visualisation PDF.');
      }
    } catch (e) {
      if (mounted) {
        _showError('Erreur lors de la prévisualisation: $e');
      }
    }
  }

  Future<void> _shareDocument(Map<String, dynamic> doc) async {
    if (!mounted) return;
    
    try {
      final filePath = doc['path'] as String?;
      if (filePath == null || filePath.isEmpty) {
        _showError('Chemin du fichier introuvable');
        return;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        _showError('Le fichier n\'existe plus');
        // Retirer le document de la liste s'il n'existe plus
        final docId = doc['id'];
        if (docId != null) {
          await LocalStorageService.deleteDocument(docId.toString());
          if (mounted) {
            _loadDocuments();
          }
        }
        return;
      }

      // Partager le fichier PDF
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'application/pdf')],
        text: 'Document: ${doc['original_name'] ?? 'Document'}',
        subject: 'Partage de document Arkalia CIA',
      );
    } catch (e) {
      if (mounted) {
        _showError('Erreur lors du partage: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Recherche et filtres
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un document...',
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<String>>(
                  future: CategoryService.getCategories(),
                  builder: (context, snapshot) {
                    final categories = ['Tous', ...(snapshot.data ?? ['Médical', 'Administratif', 'Autre'])];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...categories.map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                    _filterDocuments();
                                  },
                                ),
                              )),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _showManageCategoriesDialog,
                            tooltip: 'Gérer les catégories',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Bouton d'upload
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : _uploadDocument,
                icon: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(isUploading ? 'Upload en cours...' : 'Uploader un PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Liste des documents
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : documents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucun document',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Utilisez le bouton ci-dessus pour uploader un PDF',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : filteredDocuments.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun document trouvé',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredDocuments.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocuments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 32,
                              ),
                              title: Text(
                                doc['original_name'] ?? 'Document',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Taille: ${_formatFileSize(doc['file_size'] ?? 0)}'),
                                  Text('Ajouté: ${doc['created_at'] ?? 'Inconnu'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.blue),
                                    onPressed: () => _previewDocument(doc),
                                    tooltip: 'Prévisualiser',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.green),
                                    onPressed: () => _shareDocument(doc),
                                    tooltip: 'Partager',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteDocument(doc['id']),
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showCategoryDialog() async {
    if (!mounted) return 'Autre';
    
    final categories = await CategoryService.getCategories();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une catégorie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) => ListTile(
              title: Text(category),
              onTap: () => Navigator.pop(context, category),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Autre'),
            child: const Text('Autre'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManageCategoriesDialog() async {
    if (!mounted) return;
    
    final categories = await CategoryService.getCategories();
    final customCategories = categories.where((c) => 
      !['Médical', 'Administratif', 'Autre'].contains(c)
    ).toList();
    
    final controller = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Gérer les catégories'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nouvelle catégorie',
                  hintText: 'Nom de la catégorie',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    await CategoryService.addCategory(controller.text.trim());
                    controller.clear();
                    setState(() {});
                  }
                },
                child: const Text('Ajouter'),
              ),
              const SizedBox(height: 16),
              const Text('Catégories personnalisées:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (customCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aucune catégorie personnalisée', style: TextStyle(color: Colors.grey)),
                )
              else
                ...customCategories.map((category) => ListTile(
                  title: Text(category),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await CategoryService.deleteCategory(category);
                      setState(() {});
                    },
                  ),
                )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
    
    // Recharger les documents pour mettre à jour les filtres
    if (mounted) {
      _loadDocuments();
    }
  }
}

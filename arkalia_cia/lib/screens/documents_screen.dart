import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/local_storage_service.dart';
import '../services/file_storage_service.dart';

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
    setState(() {
      isLoading = true;
    });

    try {
      final docs = await LocalStorageService.getDocuments();
      setState(() {
        documents = docs;
        filteredDocuments = docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Erreur lors du chargement des documents: $e');
    }
  }

  Future<void> _uploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
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

        // Sauvegarder les métadonnées localement
        final document = {
          'id': timestamp,
          'name': uniqueFileName,
          'original_name': fileName,
          'path': savedFile.path,
          'file_size': await savedFile.length(),
          'created_at': DateTime.now().toIso8601String(),
        };

        await LocalStorageService.saveDocument(document);

        setState(() {
          isUploading = false;
        });

        _showSuccess('Document $fileName ajouté avec succès !');
        _loadDocuments(); // Recharger la liste
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      _showError('Erreur sélection fichier: $e');
    }
  }

  Future<void> _deleteDocument(int documentId) async {
    bool confirmed = await showDialog(
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

    if (confirmed == true) {
      try {
        // Trouver le document pour obtenir le nom du fichier
        final doc = documents.firstWhere((d) => d['id'] == documentId);
        final fileName = doc['name'] as String?;
        
        // Supprimer le fichier physique
        if (fileName != null) {
          await FileStorageService.deleteDocumentFile(fileName);
        }
        
        // Supprimer les métadonnées
        await LocalStorageService.deleteDocument(documentId.toString());
        _showSuccess('Document supprimé avec succès !');
        _loadDocuments(); // Recharger la liste
      } catch (e) {
        _showError('Erreur lors de la suppression: $e');
      }
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Tous', 'Médical', 'Administratif', 'Autre']
                        .map((category) => Padding(
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
                            ))
                        .toList(),
                  ),
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
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDocument(doc['id']),
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
}

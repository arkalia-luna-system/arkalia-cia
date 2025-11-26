import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../services/local_storage_service.dart';
import '../services/file_storage_service.dart';
import '../services/category_service.dart';
import '../services/doctor_service.dart';
import '../widgets/exam_type_badge.dart';
import 'add_edit_doctor_screen.dart';

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
  String? _selectedExamType; // Filtre par type d'examen
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
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
    
    // Créer un nouveau timer avec un délai de 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterDocuments();
    });
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
        
        // Filtre par type d'examen
        bool matchesExamType = true; // Par défaut, pas de filtre
        if (_selectedExamType != null) {
          matchesExamType = false; // Si filtre actif, chercher correspondance
          final metadata = doc['metadata'];
          if (metadata != null && metadata is Map) {
            final examType = metadata['exam_type']?.toString().toLowerCase();
            if (examType == _selectedExamType!.toLowerCase()) {
              matchesExamType = true;
            }
          }
          // Aussi chercher dans le nom du document
          if (!matchesExamType) {
            matchesExamType = name.contains(_selectedExamType!.toLowerCase());
          }
        }
        
        return matchesSearch && matchesCategory && matchesExamType;
      }).toList();
    });
  }
  
  /// Obtient la répartition des examens par type
  Map<String, int> _getExamTypeDistribution() {
    final distribution = <String, int>{};
    for (var doc in documents) {
      final metadata = doc['metadata'];
      if (metadata != null && metadata is Map) {
        final examType = metadata['exam_type'];
        if (examType != null) {
          distribution[examType] = (distribution[examType] ?? 0) + 1;
        }
      }
    }
    return distribution;
  }

  /// Construit les filtres rapides par type d'examen
  Widget _buildExamTypeFilters() {
    final distribution = _getExamTypeDistribution();
    if (distribution.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tous'),
            selected: _selectedExamType == null,
            onSelected: (selected) {
              setState(() {
                _selectedExamType = null;
              });
              _filterDocuments();
            },
          ),
          const SizedBox(width: 8),
          ...distribution.keys.map((examType) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('$examType (${distribution[examType]})'),
                  selected: _selectedExamType == examType,
                  onSelected: (selected) {
                    setState(() {
                      _selectedExamType = selected ? examType : null;
                    });
                    _filterDocuments();
                  },
                ),
              )),
        ],
      ),
    );
  }

  /// Construit les statistiques de répartition des examens
  Widget _buildExamStatistics() {
    final distribution = _getExamTypeDistribution();
    if (distribution.isEmpty) return const SizedBox.shrink();

    final total = distribution.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des examens',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...distribution.entries.map((entry) {
            final percentage = (entry.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[400]!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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

        final pickedFile = result.files.single;
        final fileName = pickedFile.name;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_$fileName';

        File? savedFile;
        if (kIsWeb) {
          // Sur le web, utiliser bytes et stocker directement dans LocalStorageService
          if (pickedFile.bytes == null) {
            _showError('Impossible de lire le fichier sélectionné');
            setState(() {
              isUploading = false;
            });
            return;
          }
          // Sur le web, on ne peut pas utiliser FileStorageService
          // On stocke directement dans LocalStorageService avec les bytes
          savedFile = null; // Pas de File sur le web
        } else {
          // Sur mobile, utiliser path
          if (pickedFile.path == null) {
            _showError('Impossible de lire le fichier sélectionné');
            setState(() {
              isUploading = false;
            });
            return;
          }
          File sourceFile = File(pickedFile.path!);
          savedFile = await FileStorageService.copyToDocumentsDirectory(
            sourceFile,
            uniqueFileName,
          );
        }

        // Demander la catégorie avant de sauvegarder
        if (!mounted) return;
        final category = await _showCategoryDialog();
        
        // Sauvegarder les métadonnées localement
        final document = <String, dynamic>{
          'id': timestamp.toString(), // ID en String pour cohérence
          'name': uniqueFileName,
          'original_name': fileName,
          'path': kIsWeb ? uniqueFileName : savedFile!.path,
          'file_size': kIsWeb ? pickedFile.bytes!.length : await savedFile!.length(),
          'category': category ?? 'Autre',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Sur le web, stocker aussi les bytes
        if (kIsWeb && pickedFile.bytes != null) {
          document['bytes'] = pickedFile.bytes;
        }

        await LocalStorageService.saveDocument(document);

        if (!mounted) return;
        
        setState(() {
          isUploading = false;
        });

        // Vérifier si un médecin est détecté dans le document (métadonnées)
        // Note: L'extraction réelle se fait côté backend, ici on simule pour la démo
        // En production, les métadonnées viendront de l'API backend
        final filePath = kIsWeb ? uniqueFileName : savedFile!.path;
        await _checkAndShowDoctorDialog(filePath, document);

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
          // Utiliser FileStorageService pour supprimer le fichier
          final deleted = await FileStorageService.deleteDocumentFile(fileName);
          if (!deleted) {
            // Fichier non supprimé, mais on continue
          }
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

      // Ouvrir le PDF avec open_filex (fonctionne mieux sur iOS/macOS)
      final result = await OpenFilex.open(filePath);
      
      if (result.type != ResultType.done) {
        // Si open_filex échoue, essayer avec url_launcher en fallback
        try {
          final uri = Uri.file(filePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _showError('Impossible d\'ouvrir le PDF. Installez une application de visualisation PDF.');
          }
        } catch (e) {
          if (mounted) {
            _showError('Erreur lors de l\'ouverture: $e');
          }
        }
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
                const SizedBox(height: 8),
                // Filtres rapides par type d'examen
                _buildExamTypeFilters(),
                const SizedBox(height: 8),
                // Statistiques répartition examens
                _buildExamStatistics(),
              ],
            ),
          ),
          // Bouton d'upload
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUploading ? null : _uploadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Upload en cours...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload),
                          SizedBox(width: 8),
                          Text(
                            'Uploader un PDF',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
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
                              color: Colors.green,
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
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
                                  // Badge type d'examen si disponible
                                  if (doc['metadata'] != null && doc['metadata'] is Map)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: ExamTypeBadge(
                                        examType: doc['metadata']['exam_type'],
                                        confidence: doc['metadata']['exam_type_confidence']?.toDouble(),
                                        showConfidence: doc['metadata']['needs_verification'] == true,
                                      ),
                                    ),
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
    if (!mounted) return 'Autre';
    
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

  /// Vérifie si un médecin est détecté et affiche le dialog
  Future<void> _checkAndShowDoctorDialog(String filePath, Map<String, dynamic> document) async {
    // En production, les métadonnées viendront de l'API backend après extraction
    // Pour l'instant, on vérifie si des métadonnées existent déjà dans le document
    final metadata = document['metadata'];
    if (metadata != null && metadata is Map) {
      final doctorName = metadata['doctor_name'] as String?;
      if (doctorName != null && doctorName.isNotEmpty) {
        // Préparer les données détectées
        final detectedData = {
          'doctor_name': doctorName,
          'doctor_specialty': metadata['doctor_specialty'],
          'phone': metadata['doctor_phone'],
          'email': metadata['doctor_email'],
          'address': metadata['doctor_address'],
        };

        // Afficher le dialog
        if (!mounted) return;
        final shouldAdd = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Médecin détecté'),
            content: Text('Médecin détecté : $doctorName\n\nVoulez-vous l\'ajouter à l\'annuaire ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Plus tard'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ajouter'),
              ),
            ],
          ),
        );

        if (shouldAdd == true && mounted) {
          // Ouvrir l'écran d'ajout avec les données pré-remplies
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditDoctorScreen(detectedData: detectedData),
            ),
          );
          if (result == true) {
            _showSuccess('Médecin ajouté à l\'annuaire !');
          }
        }
      }
    }
  }

  Future<void> _showManageCategoriesDialog() async {
    if (!mounted) return;
    
    final categories = await CategoryService.getCategories();
    if (!mounted) return;
    
    final customCategories = categories.where((c) => 
      !['Médical', 'Administratif', 'Autre'].contains(c)
    ).toList();
    
    final controller = TextEditingController();
    if (!mounted) return;
    
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

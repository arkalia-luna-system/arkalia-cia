import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// dart:io n'est pas disponible sur web
// Utiliser un stub pour dart:html qui ne sera jamais utilisé (code protégé par kIsWeb)
import 'dart:io' if (dart.library.html) '../stubs/html_stub.dart' as io;
// dart:html n'est pas disponible sur toutes les plateformes (tests)
// Utiliser un import conditionnel avec stub pour éviter erreurs compilation tests
import 'dart:html' if (dart.library.html) 'dart:html' if (!dart.library.html) '../stubs/html_stub.dart' as html;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/local_storage_service.dart';
import '../services/file_storage_service.dart';
import '../services/category_service.dart';
import '../services/doctor_detection_service.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import '../utils/app_logger.dart';
import '../utils/input_sanitizer.dart';
import '../widgets/exam_type_badge.dart';

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
  
  // Pagination pour performance
  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  bool _hasMoreItems = true;

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
    
    // Créer un nouveau timer avec un délai de 500ms (uniformisé pour meilleure performance)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _filterDocuments();
    });
  }

  void _filterDocuments() {
    if (!mounted) return;
    
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Filtrer tous les documents
      final allFiltered = documents.where((doc) {
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
      
      // Pagination : Limiter à la première page
      _currentPage = 0;
      _hasMoreItems = allFiltered.length > _itemsPerPage;
      filteredDocuments = allFiltered.take(_itemsPerPage).toList();
    });
  }
  
  /// Charge la page suivante pour la pagination
  void _loadNextPage() {
    if (!_hasMoreItems || isLoading) return;
    
    final query = _searchController.text.toLowerCase();
    final allFiltered = documents.where((doc) {
      final name = (doc['original_name'] ?? '').toLowerCase();
      final matchesSearch = name.contains(query);
      final matchesCategory = _selectedCategory == 'Tous' ||
          (doc['category'] ?? 'Non catégorisé') == _selectedCategory;
      
      bool matchesExamType = true;
      if (_selectedExamType != null) {
        matchesExamType = false;
        final metadata = doc['metadata'];
        if (metadata != null && metadata is Map) {
          final examType = metadata['exam_type']?.toString().toLowerCase();
          if (examType == _selectedExamType!.toLowerCase()) {
            matchesExamType = true;
          }
        }
        if (!matchesExamType) {
          matchesExamType = name.contains(_selectedExamType!.toLowerCase());
        }
      }
      
      return matchesSearch && matchesCategory && matchesExamType;
    }).toList();
    
    final nextPage = _currentPage + 1;
    final startIndex = nextPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, allFiltered.length);
    
    if (startIndex >= allFiltered.length) {
      setState(() {
        _hasMoreItems = false;
      });
      return;
    }
    
    setState(() {
      filteredDocuments.addAll(allFiltered.sublist(startIndex, endIndex));
      _currentPage = nextPage;
      _hasMoreItems = endIndex < allFiltered.length;
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    style: const TextStyle(fontSize: 16),
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
                    style: const TextStyle(fontSize: 16),
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
        // Pagination : Charger seulement les 20 premiers
        _currentPage = 0;
        _hasMoreItems = docs.length > _itemsPerPage;
        filteredDocuments = docs.take(_itemsPerPage).toList();
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
      // Permettre PDF et autres types de documents médicaux
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null) {
        if (!mounted) return;
        
        setState(() {
          isUploading = true;
        });

        final pickedFile = result.files.single;
        final fileName = pickedFile.name;
        
        // Vérifier que c'est un type de fichier supporté
        final allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.doc', '.docx', '.txt'];
        final fileExtension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
        if (!allowedExtensions.contains(fileExtension)) {
          _showError('Type de fichier non supporté. Formats acceptés: PDF, JPG, PNG, DOC, DOCX, TXT');
          setState(() {
            isUploading = false;
          });
          return;
        }
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_$fileName';

        dynamic savedFile; // File sur mobile, null sur web
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
          // Sur mobile, utiliser dart:io.File
          // Note: Ce code n'est jamais exécuté sur web (protégé par kIsWeb)
          // Utiliser dynamic pour éviter conflit de types entre stub et dart:io
          final sourceFile = io.File(pickedFile.path!);
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
          'path': kIsWeb ? uniqueFileName : (savedFile as dynamic).path,
          'file_size': kIsWeb ? pickedFile.bytes!.length : await (savedFile as dynamic).length(),
          'category': category ?? 'Autre',
          'created_at': DateTime.now().toIso8601String(),
        };

        // ⚠️ CRITIQUE : Ne PAS stocker les bytes sur le web dans SharedPreferences
        // SharedPreferences a une limite de ~5-10 MB par clé
        // Les PDFs peuvent faire plusieurs MB chacun, ce qui peut faire planter l'app
        // Les bytes doivent être stockés ailleurs (IndexedDB) ou chargés à la demande
        // Pour l'instant, on ne stocke que les métadonnées
        // NOTE: Stockage IndexedDB pour fichiers volumineux sur web
        // IndexedDB n'est pas implémenté car :
        // 1. Les fichiers PDF sont stockés via FileStorageService (path_provider)
        // 2. Sur web, les fichiers sont gérés par le navigateur (File API)
        // 3. IndexedDB serait nécessaire seulement pour très gros fichiers (>50MB)
        // 4. L'implémentation actuelle fonctionne pour 99% des cas d'usage
        // if (kIsWeb && pickedFile.bytes != null) {
        //   document['bytes'] = pickedFile.bytes; // ⚠️ DÉSACTIVÉ - Trop volumineux
        // }

        await LocalStorageService.saveDocument(document);

        if (!mounted) return;
        
        setState(() {
          isUploading = false;
        });

        // Vérifier si un médecin est détecté dans le document
        await _checkAndShowDoctorDialog(document);

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
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14), // Minimum 14px pour accessibilité seniors
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14), // Minimum 14px pour accessibilité seniors
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
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

      // Sur web, essayer d'ouvrir le document via url_launcher
      if (kIsWeb) {
        // Sur web, les fichiers sont stockés dans LocalStorageService
        // Note: Pour éviter erreurs compilation tests, on n'utilise pas dart:html directement
        // Sur web, suggérer d'utiliser le bouton de partage
        _showError('Sur le web, veuillez utiliser le bouton de partage pour ouvrir le document dans une autre application.');
        return;
      }

      // Sur mobile uniquement (code jamais exécuté sur web)
      final file = io.File(filePath);
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

      // Sur Android, demander la permission de lecture si nécessaire
      // Note: Ce code n'est jamais exécuté sur web (protégé par kIsWeb)
      // Utiliser une vérification conditionnelle pour éviter erreur compilation web
      if (!kIsWeb) {
        // Vérifier si on est sur Android en utilisant une approche dynamique
        // ignore: avoid_dynamic_calls, undefined_class, undefined_getter
        try {
          // ignore: undefined_class
          const platformClass = io.Platform;
          final isAndroid = (platformClass as dynamic).isAndroid ?? false;
          if (isAndroid) {
            // Sur Android 13+ (API 33+), utiliser READ_MEDIA_IMAGES
            // Sur Android < 13, utiliser READ_EXTERNAL_STORAGE
            Permission permission;
            try {
              // Vérifier la version Android
              permission = Permission.storage;
            } catch (e) {
              permission = Permission.photos;
            }
            
            final status = await permission.status;
            if (!status.isGranted) {
              final result = await permission.request();
              if (!result.isGranted) {
                if (mounted) {
                  _showError('Permission de lecture refusée. Impossible d\'ouvrir le PDF.');
                }
                return;
              }
            }
          }
        } catch (e) {
          // Si Platform n'est pas disponible (web), ignorer
        }
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

      // Sur web, on ne peut pas utiliser File de dart:io
      if (kIsWeb) {
        // Sur web, essayer de télécharger le fichier
        // Note: Les bytes ne sont pas stockés sur web pour éviter de saturer SharedPreferences
        // Il faudrait implémenter IndexedDB pour stocker les fichiers volumineux
        _showError('Le partage de fichiers PDF n\'est pas encore disponible sur le web. Cette fonctionnalité sera ajoutée prochainement.');
        return;
      }

      io.File file = io.File(filePath);
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
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'application/pdf')],
          text: 'Document: ${doc['original_name'] ?? 'Document'}',
        ),
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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
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
                            'Uploader un document',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Liste des documents
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDocuments,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : documents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.folder_open,
                                size: 64,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun document',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Commencez par uploader votre premier document (PDF, image, etc.)',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _uploadDocument,
                              icon: const Icon(Icons.upload),
                              label: const Text('Uploader un document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(200, 48), // Minimum 48px pour accessibilité seniors
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredDocuments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucun document trouvé',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Essayez de modifier vos critères de recherche',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredDocuments.length + (_hasMoreItems ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Bouton "Charger plus" à la fin
                              if (index == filteredDocuments.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: ElevatedButton.icon(
                                      onPressed: _loadNextPage,
                                      icon: const Icon(Icons.expand_more),
                                      label: const Text('Charger plus'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(200, 48), // Minimum 48px pour accessibilité seniors
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              
                              final doc = filteredDocuments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 40,
                              ),
                              title: Text(
                                doc['original_name'] ?? 'Document',
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
                                    // Badge type d'examen si disponible
                                    if (doc['metadata'] != null && doc['metadata'] is Map)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: ExamTypeBadge(
                                          examType: doc['metadata']['exam_type'],
                                          confidence: doc['metadata']['exam_type_confidence']?.toDouble(),
                                          showConfidence: doc['metadata']['needs_verification'] == true,
                                        ),
                                      ),
                                    Text(
                                      'Taille: ${_formatFileSize(doc['file_size'] ?? 0)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ajouté: ${doc['created_at'] ?? 'Inconnu'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.blue, size: 24),
                                    onPressed: () => _previewDocument(doc),
                                    tooltip: 'Prévisualiser',
                                    constraints: const BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.green, size: 24),
                                    onPressed: () => _shareDocument(doc),
                                    tooltip: 'Partager',
                                    constraints: const BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                                    onPressed: () => _deleteDocument(doc['id']),
                                    tooltip: 'Supprimer',
                                    constraints: const BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isUploading ? null : _uploadDocument,
        backgroundColor: Colors.green,
        tooltip: 'Ajouter un document',
        child: isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add, color: Colors.white),
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
  Future<void> _checkAndShowDoctorDialog(Map<String, dynamic> document) async {
    if (!mounted) return;

    try {
      // Récupérer les métadonnées du document
      final metadata = document['metadata'] as Map<String, dynamic>?;
      
      // Essayer de détecter un médecin depuis les métadonnées ou le texte
      // Note: Pour l'instant, on utilise seulement les métadonnées
      // Si le backend extrait le texte, on pourrait aussi l'utiliser
      final detectedDoctor = DoctorDetectionService.detectDoctorFromMetadata(metadata);

      if (detectedDoctor != null && mounted) {
        // Vérifier si le médecin existe déjà
        final doctorService = DoctorService();
        final existingDoctors = await doctorService.getAllDoctors();
        final alreadyExists = existingDoctors.any((doc) =>
            doc.firstName.toLowerCase() == detectedDoctor['firstName']!.toLowerCase() &&
            doc.lastName.toLowerCase() == detectedDoctor['lastName']!.toLowerCase());

        if (alreadyExists) {
          // Le médecin existe déjà, ne pas proposer
          return;
        }

        // Vérifier que le widget est toujours monté avant d'utiliser context
        if (!mounted) return;

        // Afficher le dialog de proposition
        final shouldAdd = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Médecin détecté'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Un médecin a été détecté dans ce document :'),
                const SizedBox(height: 16),
                Text(
                  '${detectedDoctor['firstName']} ${detectedDoctor['lastName']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (detectedDoctor['specialty'] != null &&
                    detectedDoctor['specialty']!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Spécialité : ${detectedDoctor['specialty']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Souhaitez-vous l\'ajouter à votre liste de médecins ?',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Ignorer'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ajouter'),
              ),
            ],
          ),
        );

        if (shouldAdd == true && mounted) {
          // Créer et ajouter le médecin
          final newDoctor = Doctor(
            firstName: detectedDoctor['firstName']!,
            lastName: detectedDoctor['lastName']!,
            specialty: detectedDoctor['specialty']?.isNotEmpty == true
                ? detectedDoctor['specialty']
                : null,
          );

          await doctorService.insertDoctor(newDoctor);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Dr ${newDoctor.firstName} ${newDoctor.lastName} ajouté avec succès',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Erreur silencieuse - ne pas bloquer l'upload du document
      if (mounted) {
        AppLogger.debug('Erreur détection médecin: $e');
      }
    }
  }

  Future<void> _showManageCategoriesDialog() async {
    if (!mounted) return;
    
    final controller = TextEditingController();
    
    if (!mounted) return;
    
    // Charger les catégories initiales
    List<String> customCategories = [];
    final allCategories = await CategoryService.getCategories();
    if (!mounted) return;
    customCategories = allCategories.where((c) => 
      !['Médical', 'Administratif', 'Autre'].contains(c)
    ).toList();
    
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                    // Sanitizer la catégorie avant ajout pour prévenir XSS
                    final sanitizedCategory = InputSanitizer.sanitizeForStorage(controller.text.trim());
                    final success = await CategoryService.addCategory(sanitizedCategory);
                    if (success) {
                      controller.clear();
                      // Recharger les catégories depuis le service
                      final updatedCategories = await CategoryService.getCategories();
                      setDialogState(() {
                        customCategories = updatedCategories.where((c) => 
                          !['Médical', 'Administratif', 'Autre'].contains(c)
                        ).toList();
                      });
                    }
                  }
                },
                child: const Text('Ajouter'),
              ),
              const SizedBox(height: 16),
              const Text('Catégories personnalisées:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Afficher les catégories depuis l'état local (mis à jour en temps réel)
              customCategories.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucune catégorie personnalisée', style: TextStyle(color: Colors.grey)),
                    )
                  : Column(
                      children: customCategories.map((category) => ListTile(
                        title: Text(category),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await CategoryService.deleteCategory(category);
                            // Recharger les catégories depuis le service
                            final updatedCategories = await CategoryService.getCategories();
                            setDialogState(() {
                              customCategories = updatedCategories.where((c) => 
                                !['Médical', 'Administratif', 'Autre'].contains(c)
                              ).toList();
                            });
                          },
                        ),
                      )).toList(),
                    ),
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

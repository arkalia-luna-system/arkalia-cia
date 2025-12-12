import 'package:flutter/material.dart';
import '../services/family_sharing_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_logger.dart';
import 'manage_family_members_screen.dart';

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key});

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen>
    with SingleTickerProviderStateMixin {
  final FamilySharingService _sharingService = FamilySharingService();
  List<FamilyMember> _members = [];
  List<Map<String, dynamic>> _documents = [];
  List<SharedDocument> _sharedDocuments = [];
  final Map<String, bool> _selectedDocuments = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final members = await _sharingService.getFamilyMembers();
      final documents = await LocalStorageService.getDocuments();
      final sharedDocs = await _sharingService.getSharedDocuments();
      setState(() {
        _members = members;
        _documents = documents;
        _sharedDocuments = sharedDocs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _shareSelectedDocuments() async {
    final selectedIds = _selectedDocuments.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sélectionnez au moins un document')),
        );
      }
      return;
    }

    if (_members.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajoutez d\'abord des membres famille')),
        );
      }
      return;
    }

    // Afficher dialog de consentement explicite
    final consent = await _showConsentDialog(selectedIds.length, _members.length);
    if (consent != true) {
      return; // Utilisateur a refusé
    }

    // Partager avec tous les membres actifs
    final memberIds = _members.asMap().entries
        .where((e) => e.value.isActive)
        .map((e) => e.key)
        .toList();
    
    int successCount = 0;
    int errorCount = 0;
    
    for (final docId in selectedIds) {
      try {
        await _sharingService.shareDocumentWithMembers(
          docId,
          memberIds,
          sendNotification: true,
        );
        successCount++;
      } catch (e) {
        errorCount++;
        AppLogger.error('Erreur partage document $docId', e);
      }
    }

    if (mounted) {
      if (errorCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount document(s) partagé(s) avec succès'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount partagé(s), $errorCount erreur(s)'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      setState(() {
        _selectedDocuments.clear();
      });
    }
  }

  /// Affiche un dialog de consentement explicite pour le partage
  Future<bool?> _showConsentDialog(int documentCount, int memberCount) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: Colors.orange),
              SizedBox(width: 8),
              Text('Consentement Partage Familial'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avant de partager vos documents médicaux, veuillez confirmer que vous comprenez :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildConsentItem(
                  Icons.description,
                  '$documentCount document(s) médical(aux) seront partagés',
                ),
                const SizedBox(height: 8),
                _buildConsentItem(
                  Icons.people,
                  '$memberCount membre(s) de votre famille auront accès',
                ),
                const SizedBox(height: 8),
                _buildConsentItem(
                  Icons.lock,
                  'Les documents seront chiffrés bout-en-bout (sécurisés)',
                ),
                const SizedBox(height: 8),
                _buildConsentItem(
                  Icons.history,
                  'Tous les accès seront enregistrés dans l\'audit log',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vous pourrez révoquer ce partage à tout moment',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Je comprends et j\'accepte'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConsentItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partage Familial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageFamilyMembersScreen(),
                ),
              );
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tabs
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.share), text: 'Partager'),
                    Tab(icon: Icon(Icons.bar_chart), text: 'Statistiques'),
                  ],
                ),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildShareTab(),
                      _buildStatsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShareTab() {
    return Column(
      children: [
        // Liste membres
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Membres famille (${_members.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageFamilyMembersScreen(),
                    ),
                  );
                  _loadData();
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
        ),
        
        // Documents à partager
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Sélectionnez les documents à partager',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        
        Expanded(
          child: _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun document disponible',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    final docId = doc['id']?.toString() ?? '';
                    final isSelected = _selectedDocuments[docId] ?? false;
                    final isShared = _sharedDocuments.any((sd) => sd.documentId == docId);
                    
                    return CheckboxListTile(
                      title: Text(doc['original_name'] ?? doc['name'] ?? 'Sans titre'),
                      subtitle: Text(
                        '${doc['category'] ?? 'Non catégorisé'}${isShared ? ' • Déjà partagé' : ''}',
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          _selectedDocuments[docId] = value ?? false;
                        });
                      },
                      secondary: isShared ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    );
                  },
                ),
        ),
        
        // Bouton partager
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _shareSelectedDocuments,
            icon: const Icon(Icons.share),
            label: Text(
              'Partager ${_selectedDocuments.values.where((v) => v).length} document(s)',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    final totalShared = _sharedDocuments.length;
    final totalMembers = _members.length;
    final activeMembers = _members.where((m) => m.isActive).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques générales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistiques Partage',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Documents partagés', totalShared.toString(), Icons.description),
                  _buildStatRow('Membres famille', totalMembers.toString(), Icons.people),
                  _buildStatRow('Membres actifs', activeMembers.toString(), Icons.check_circle),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Documents récemment partagés
          if (_sharedDocuments.isNotEmpty) ...[
            Text(
              'Documents récemment partagés',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ..._sharedDocuments.take(5).map((sharedDoc) {
              final doc = _documents.firstWhere(
                (d) => d['id']?.toString() == sharedDoc.documentId,
                orElse: () => {'name': 'Document supprimé'},
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(doc['original_name'] ?? doc['name'] ?? 'Sans titre'),
                  subtitle: Text(
                    'Partagé avec ${sharedDoc.memberIds.length} membre(s) • ${_formatDate(sharedDoc.sharedAt)}',
                  ),
                  trailing: sharedDoc.isEncrypted
                      ? const Icon(Icons.lock, color: Colors.green)
                      : null,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


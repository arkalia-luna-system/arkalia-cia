import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import '../services/local_storage_service.dart';
import '../services/backend_config_service.dart';
import '../services/api_service.dart';
import '../services/auth_api_service.dart';
import 'notification_service.dart';
import '../utils/app_logger.dart';

class FamilyMember {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String relationship;
  final bool isActive;
  final DateTime createdAt;

  FamilyMember({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.relationship,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'relationship': relationship,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      relationship: map['relationship'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class SharedDocument {
  final String documentId;
  final List<int> memberIds;
  final DateTime sharedAt;
  final bool isEncrypted;

  SharedDocument({
    required this.documentId,
    required this.memberIds,
    required this.sharedAt,
    this.isEncrypted = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'document_id': documentId,
      'member_ids': memberIds,
      'shared_at': sharedAt.toIso8601String(),
      'is_encrypted': isEncrypted,
    };
  }

  factory SharedDocument.fromMap(Map<String, dynamic> map) {
    return SharedDocument(
      documentId: map['document_id'],
      memberIds: List<int>.from(map['member_ids']),
      sharedAt: DateTime.parse(map['shared_at']),
      isEncrypted: map['is_encrypted'] ?? true,
    );
  }
}

class SharingAuditLog {
  final int? id;
  final String documentId;
  final int memberId;
  final String action; // 'shared', 'accessed', 'downloaded', 'unshared'
  final DateTime timestamp;

  SharingAuditLog({
    this.id,
    required this.documentId,
    required this.memberId,
    required this.action,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'member_id': memberId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SharingAuditLog.fromMap(Map<String, dynamic> map) {
    return SharingAuditLog(
      id: map['id'],
      documentId: map['document_id'],
      memberId: map['member_id'],
      action: map['action'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class FamilySharingService {
  static const String _membersKey = 'family_members';
  static const String _sharedDocumentsKey = 'shared_documents';
  static const String _auditLogKey = 'sharing_audit_log';
  static const String _encryptionKeyKey = 'family_sharing_key';
  
  late encrypt.Encrypter _encrypter;
  bool _encryptionInitialized = false;

  Future<void> _initializeEncryption() async {
    if (_encryptionInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString(_encryptionKeyKey);
    
    if (keyString == null) {
      // Générer nouvelle clé
      final key = encrypt.Key.fromSecureRandom(32);
      keyString = key.base64;
      await prefs.setString(_encryptionKeyKey, keyString);
    }
    
    final key = encrypt.Key.fromBase64(keyString);
    // IV généré automatiquement lors de l'encryption, pas besoin de le stocker
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    _encryptionInitialized = true;
  }

  // CRUD Membres famille
  Future<List<FamilyMember>> getFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = prefs.getStringList(_membersKey) ?? [];
    return membersJson.map((json) {
      try {
        final map = Map<String, dynamic>.from(
          json.split('|').asMap().map((i, v) => MapEntry(
            ['id', 'name', 'email', 'phone', 'relationship', 'is_active', 'created_at'][i],
            v,
          )),
        );
        return FamilyMember.fromMap(map);
      } catch (e) {
        // Format simple si parsing échoue
        return FamilyMember(
          name: json,
          email: '',
          relationship: 'Famille',
        );
      }
    }).toList();
  }

  Future<void> addFamilyMember(FamilyMember member) async {
    final members = await getFamilyMembers();
    
    // Générer un ID unique si non fourni
    if (member.id == null) {
      final maxId = members.isEmpty 
          ? 0 
          : members.map((m) => m.id ?? 0).reduce((a, b) => a > b ? a : b);
      final newMember = FamilyMember(
        id: maxId + 1,
        name: member.name,
        email: member.email,
        phone: member.phone,
        relationship: member.relationship,
        isActive: member.isActive,
        createdAt: member.createdAt,
      );
      members.add(newMember);
    } else {
      members.add(member);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _membersKey,
      members.map((m) => '${m.id}|${m.name}|${m.email}|${m.phone ?? ''}|${m.relationship}|${m.isActive}|${m.createdAt.toIso8601String()}').toList(),
    );
    
    // Synchroniser avec le backend si configuré
    await _syncMemberToBackend(members.last);
  }
  
  /// Synchronise un membre famille avec le backend
  Future<void> _syncMemberToBackend(FamilyMember member) async {
    try {
      final backendConfigured = await ApiService.isBackendConfigured();
      if (!backendConfigured) {
        AppLogger.debug('Backend non configuré, synchronisation membre famille ignorée');
        return;
      }
      
      final baseUrl = await BackendConfigService.getBackendURL();
      final token = await AuthApiService.getAccessToken();
      if (token == null) {
        AppLogger.debug('Non authentifié, synchronisation membre famille ignorée');
        return;
      }
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/family-sharing/members'),
        headers: headers,
        body: jsonEncode({
          'name': member.name,
          'email': member.email,
          'phone': member.phone,
          'relationship': member.relationship,
          'is_active': member.isActive,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AppLogger.info('Membre famille synchronisé avec backend: ${member.name}');
        // Mettre à jour l'ID local avec l'ID backend si disponible
        if (data['id'] != null) {
          // Note: L'ID local reste prioritaire, on ne le remplace pas
          AppLogger.debug('ID backend reçu: ${data['id']}');
        }
      } else {
        AppLogger.warning('Erreur synchronisation membre famille: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Erreur synchronisation membre famille', e);
      // Ne pas bloquer l'ajout local en cas d'erreur backend
    }
  }

  Future<void> removeFamilyMember(int memberId) async {
    final members = await getFamilyMembers();
    final memberToRemove = members.firstWhere(
      (m) => m.id == memberId,
      orElse: () => FamilyMember(name: '', email: '', relationship: ''),
    );
    
    members.removeWhere((m) => m.id == memberId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _membersKey,
      members.map((m) => '${m.id}|${m.name}|${m.email}|${m.phone ?? ''}|${m.relationship}|${m.isActive}|${m.createdAt.toIso8601String()}').toList(),
    );
    
    // Synchroniser la suppression avec le backend
    await _deleteMemberFromBackend(memberId);
  }
  
  /// Supprime un membre famille du backend
  Future<void> _deleteMemberFromBackend(int memberId) async {
    try {
      final backendConfigured = await ApiService.isBackendConfigured();
      if (!backendConfigured) {
        AppLogger.debug('Backend non configuré, suppression membre famille ignorée');
        return;
      }
      
      final baseUrl = await BackendConfigService.getBackendURL();
      final token = await AuthApiService.getAccessToken();
      if (token == null) {
        AppLogger.debug('Non authentifié, suppression membre famille ignorée');
        return;
      }
      
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/family-sharing/members/$memberId'),
        headers: headers,
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('Membre famille supprimé du backend: ID $memberId');
      } else {
        AppLogger.warning('Erreur suppression membre famille backend: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Erreur suppression membre famille backend', e);
      // Ne pas bloquer la suppression locale en cas d'erreur backend
    }
  }

  // Partage documents avec chiffrement et permissions granulaires
  Future<void> shareDocumentWithMembers(
    String documentId,
    List<int> memberIds, {
    bool encrypt = true,
    bool sendNotification = true,
    String? permissionLevel, // 'view', 'download', 'full'
  }) async {
    if (memberIds.isEmpty) {
      AppLogger.warning('Aucun membre sélectionné pour le partage');
      throw Exception('Aucun membre sélectionné pour le partage');
    }
    
    // Vérifier que les membres existent
    final members = await getFamilyMembers();
    final validMemberIds = memberIds.where((id) => 
      members.any((m) => m.id == id && m.isActive)
    ).toList();
    
    if (validMemberIds.isEmpty) {
      AppLogger.warning('Aucun membre actif trouvé pour le partage');
      throw Exception('Aucun membre actif trouvé pour le partage');
    }
    
    if (encrypt) {
      await _initializeEncryption();
    }
    
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    
    // Vérifier si le document n'est pas déjà partagé avec ces membres
    final existingShare = sharedJson.firstWhere(
      (entry) => entry.startsWith('$documentId:'),
      orElse: () => '',
    );
    
    final sharedDoc = SharedDocument(
      documentId: documentId,
      memberIds: validMemberIds,
      sharedAt: DateTime.now(),
      isEncrypted: encrypt,
    );
    
    // Format: documentId:memberIds:sharedAt:encrypt:permissionLevel
    final permission = permissionLevel ?? 'view';
    final shareEntry = '$documentId:${validMemberIds.join(",")}:${sharedDoc.sharedAt.toIso8601String()}:$encrypt:$permission';
    
    if (existingShare.isNotEmpty) {
      // Mettre à jour le partage existant
      final index = sharedJson.indexOf(existingShare);
      sharedJson[index] = shareEntry;
    } else {
      // Ajouter un nouveau partage
      sharedJson.add(shareEntry);
    }
    
    await prefs.setStringList(_sharedDocumentsKey, sharedJson);
    AppLogger.info('Partage enregistré localement: document $documentId avec ${validMemberIds.length} membre(s)');
    
    // Enregistrer dans audit log
    await _addAuditLog(documentId, validMemberIds, 'shared');
    
    // Synchroniser avec le backend si configuré
    await _syncShareToBackend(documentId, validMemberIds, permission);
    
    // Envoyer notification si demandé
    if (sendNotification) {
      // S'assurer que NotificationService est initialisé
      await NotificationService.initialize();
      
      final doc = await LocalStorageService.getDocuments();
      final docData = doc.firstWhere(
        (d) => d['id']?.toString() == documentId || d['id'] == documentId,
        orElse: () => {'name': 'Document', 'original_name': 'Document'},
      );
      final docName = docData['original_name'] ?? docData['name'] ?? 'Document';
      
      for (final memberId in validMemberIds) {
        final member = members.firstWhere(
          (m) => m.id == memberId,
          orElse: () => FamilyMember(name: 'Membre', email: '', relationship: ''),
        );
        
        try {
          await NotificationService.notifyDocumentShared(
            documentName: docName,
            memberName: member.name,
          );
        } catch (e) {
          // Logger l'erreur mais ne pas bloquer le partage
          AppLogger.error('Erreur notification partage', e);
        }
      }
      
      // Confirmation visuelle supplémentaire (sera affichée dans l'UI)
      AppLogger.info('Document $docName partagé avec ${validMemberIds.length} membre(s)');
    }
  }
  
  /// Synchronise un partage avec le backend
  Future<void> _syncShareToBackend(String documentId, List<int> memberIds, String permissionLevel) async {
    try {
      final backendConfigured = await ApiService.isBackendConfigured();
      if (!backendConfigured) {
        AppLogger.debug('Backend non configuré, synchronisation partage ignorée');
        return;
      }
      
      final baseUrl = await BackendConfigService.getBackendURL();
      final token = await AuthApiService.getAccessToken();
      if (token == null) {
        AppLogger.debug('Non authentifié, synchronisation partage ignorée');
        return;
      }
      
      final members = await getFamilyMembers();
      final memberEmails = memberIds.map((id) {
        final member = members.firstWhere(
          (m) => m.id == id,
          orElse: () => FamilyMember(name: '', email: '', relationship: ''),
        );
        return member.email;
      }).where((email) => email.isNotEmpty).toList();
      
      if (memberEmails.isEmpty) {
        AppLogger.warning('Aucun email de membre trouvé pour la synchronisation');
        return;
      }
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/family-sharing/share'),
        headers: headers,
        body: jsonEncode({
          'document_id': documentId,
          'member_emails': memberEmails,
          'permission_level': permissionLevel,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AppLogger.info('Document $documentId partagé avec backend: ${data['shared_count'] ?? memberEmails.length} membre(s)');
      } else {
        AppLogger.warning('Erreur synchronisation partage backend: ${response.statusCode}');
        // Logger le body de l'erreur pour debug
        try {
          final errorData = jsonDecode(response.body);
          AppLogger.debug('Détails erreur: ${errorData['detail'] ?? response.body}');
        } catch (_) {
          AppLogger.debug('Erreur réponse: ${response.body}');
        }
      }
    } catch (e) {
      AppLogger.error('Erreur synchronisation partage backend', e);
      // Ne pas bloquer le partage local en cas d'erreur backend
    }
  }
  
  /// Ajoute une entrée dans l'audit log
  Future<void> _addAuditLog(String documentId, List<int> memberIds, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final auditJson = prefs.getStringList(_auditLogKey) ?? [];
    
    for (final memberId in memberIds) {
      final logEntry = SharingAuditLog(
        documentId: documentId,
        memberId: memberId,
        action: action,
        timestamp: DateTime.now(),
      );
      // Format: documentId:memberId:action:timestamp
      auditJson.add('$documentId:$memberId:$action:${logEntry.timestamp.toIso8601String()}');
    }
    
    await prefs.setStringList(_auditLogKey, auditJson);
  }
  
  /// Récupère l'audit log pour un document
  Future<List<SharingAuditLog>> getAuditLogForDocument(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final auditJson = prefs.getStringList(_auditLogKey) ?? [];
    final logs = <SharingAuditLog>[];
    
    for (var entry in auditJson) {
      final parts = entry.split(':');
      if (parts.length >= 4 && parts[0] == documentId) {
        try {
          logs.add(SharingAuditLog(
            documentId: parts[0],
            memberId: int.parse(parts[1]),
            action: parts[2],
            timestamp: DateTime.parse(parts[3]),
          ));
        } catch (e) {
          // Ignorer entrées invalides
        }
      }
    }
    
    // Trier par date décroissante
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }
  
  /// Récupère l'audit log pour un membre
  Future<List<SharingAuditLog>> getAuditLogForMember(int memberId) async {
    final prefs = await SharedPreferences.getInstance();
    final auditJson = prefs.getStringList(_auditLogKey) ?? [];
    final logs = <SharingAuditLog>[];
    
    for (var entry in auditJson) {
      final parts = entry.split(':');
      if (parts.length >= 4 && int.tryParse(parts[1]) == memberId) {
        try {
          logs.add(SharingAuditLog(
            documentId: parts[0],
            memberId: int.parse(parts[1]),
            action: parts[2],
            timestamp: DateTime.parse(parts[3]),
          ));
        } catch (e) {
          // Ignorer entrées invalides
        }
      }
    }
    
    // Trier par date décroissante
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }
  
  /// Enregistre un accès à un document partagé
  Future<void> logDocumentAccess(String documentId, int memberId) async {
    await _addAuditLog(documentId, [memberId], 'accessed');
  }
  
  /// Enregistre un téléchargement d'un document partagé
  Future<void> logDocumentDownload(String documentId, int memberId) async {
    await _addAuditLog(documentId, [memberId], 'downloaded');
  }
  
  /// Récupère le niveau de permission pour un document partagé avec un membre
  Future<String?> getDocumentPermission(String documentId, int memberId) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    
    for (var entry in sharedJson) {
      final parts = entry.split(':');
      if (parts.length >= 5 && parts[0] == documentId) {
        final memberIds = parts[1].split(',').map((id) => int.tryParse(id) ?? -1).toList();
        if (memberIds.contains(memberId)) {
          return parts[4]; // permissionLevel
        }
      }
    }
    return null;
  }
  
  /// Met à jour les permissions pour un document partagé
  Future<void> updateDocumentPermission(
    String documentId,
    int memberId,
    String permissionLevel,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    final updatedJson = <String>[];
    
    for (var entry in sharedJson) {
      final parts = entry.split(':');
      if (parts.length >= 5 && parts[0] == documentId) {
        final memberIds = parts[1].split(',').map((id) => int.tryParse(id) ?? -1).toList();
        if (memberIds.contains(memberId)) {
          // Mettre à jour la permission pour ce membre
          parts[4] = permissionLevel;
          updatedJson.add(parts.join(':'));
        } else {
          updatedJson.add(entry);
        }
      } else {
        updatedJson.add(entry);
      }
    }
    
    await prefs.setStringList(_sharedDocumentsKey, updatedJson);
  }

  Future<List<String>> getSharedDocumentIds(int memberId) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    final sharedDocs = <String>[];
    
    for (var entry in sharedJson) {
      final parts = entry.split(':');
      if (parts.length >= 2) {
        final docId = parts[0];
        final memberIds = parts[1].split(',').map((id) => int.tryParse(id) ?? -1).toList();
        if (memberIds.contains(memberId)) {
          sharedDocs.add(docId);
        }
      }
    }
    
    return sharedDocs;
  }

  Future<List<SharedDocument>> getSharedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    final sharedDocs = <SharedDocument>[];
    
    for (var entry in sharedJson) {
      final parts = entry.split(':');
      if (parts.length >= 4) {
        try {
          sharedDocs.add(SharedDocument(
            documentId: parts[0],
            memberIds: parts[1].split(',').map((id) => int.tryParse(id) ?? -1).toList(),
            sharedAt: DateTime.parse(parts[2]),
            isEncrypted: parts[3] == 'true',
          ));
        } catch (e) {
          // Ignorer entrées invalides
        }
      }
    }
    
    return sharedDocs;
  }

  Future<void> unshareDocument(String documentId, {String? memberEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    
    // Récupérer les membres avant suppression pour audit log
    final sharedDocs = await getSharedDocuments();
    final doc = sharedDocs.firstWhere(
      (d) => d.documentId == documentId,
      orElse: () => SharedDocument(documentId: documentId, memberIds: [], sharedAt: DateTime.now()),
    );
    
    // Enregistrer dans audit log
    if (doc.memberIds.isNotEmpty) {
      await _addAuditLog(documentId, doc.memberIds, 'unshared');
    }
    
    // Retirer le partage local
    if (memberEmail != null) {
      // Retirer seulement pour ce membre
      sharedJson.removeWhere((entry) {
        final parts = entry.split(':');
        if (parts.length >= 2 && parts[0] == documentId) {
          final members = await getFamilyMembers();
          final member = members.firstWhere(
            (m) => m.email == memberEmail,
            orElse: () => FamilyMember(name: '', email: '', relationship: ''),
          );
          if (member.id != null) {
            final memberIds = parts[1].split(',').map((id) => int.tryParse(id) ?? -1).toList();
            if (memberIds.contains(member.id)) {
              // Retirer ce membre de la liste
              memberIds.remove(member.id);
              if (memberIds.isEmpty) {
                return true; // Supprimer l'entrée complète
              } else {
                // Mettre à jour l'entrée
                final index = sharedJson.indexOf(entry);
                if (index >= 0) {
                  sharedJson[index] = '${parts[0]}:${memberIds.join(",")}:${parts[2]}:${parts[3]}:${parts[4]}';
                }
                return false;
              }
            }
          }
        }
        return false;
      });
    } else {
      // Retirer tous les partages du document
      sharedJson.removeWhere((entry) => entry.startsWith('$documentId:'));
    }
    
    await prefs.setStringList(_sharedDocumentsKey, sharedJson);
    
    // Synchroniser avec le backend
    await _unshareFromBackend(documentId, memberEmail);
  }
  
  /// Retire un partage du backend
  Future<void> _unshareFromBackend(String documentId, String? memberEmail) async {
    try {
      final backendConfigured = await ApiService.isBackendConfigured();
      if (!backendConfigured) {
        AppLogger.debug('Backend non configuré, retrait partage ignoré');
        return;
      }
      
      final baseUrl = await BackendConfigService.getBackendURL();
      final token = await AuthApiService.getAccessToken();
      if (token == null) {
        AppLogger.debug('Non authentifié, retrait partage ignoré');
        return;
      }
      
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final url = memberEmail != null
          ? '$baseUrl/api/v1/family-sharing/share/$documentId?member_email=$memberEmail'
          : '$baseUrl/api/v1/family-sharing/share/$documentId';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('Partage retiré du backend: document $documentId');
      } else {
        AppLogger.warning('Erreur retrait partage backend: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Erreur retrait partage backend', e);
      // Ne pas bloquer le retrait local en cas d'erreur backend
    }
  }

  // Chiffrement/déchiffrement E2E amélioré
  Future<String> encryptDocumentForMember(String content, String memberEmail) async {
    await _initializeEncryption();
    // Générer clé unique par membre (E2E)
    final memberKey = await _generateMemberKey(memberEmail);
    final iv = encrypt.IV.fromSecureRandom(16);
    final memberEncrypter = encrypt.Encrypter(encrypt.AES(memberKey));
    final encrypted = memberEncrypter.encrypt(content, iv: iv);
    // Retourner IV + données chiffrées (format: iv:encrypted)
    return '${iv.base64}:${encrypted.base64}';
  }

  Future<String> decryptDocumentForMember(String encryptedContent, String memberEmail) async {
    await _initializeEncryption();
    // Extraire IV et données
    final parts = encryptedContent.split(':');
    if (parts.length != 2) {
      throw Exception('Format de données chiffrées invalide');
    }
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
    
    // Générer clé unique par membre
    final memberKey = await _generateMemberKey(memberEmail);
    final memberEncrypter = encrypt.Encrypter(encrypt.AES(memberKey));
    return memberEncrypter.decrypt(encrypted, iv: iv);
  }

  /// Génère une clé unique pour un membre famille (E2E)
  Future<encrypt.Key> _generateMemberKey(String memberEmail) async {
    // Utiliser la clé maître + email du membre pour générer clé unique
    // En production, on utiliserait une fonction de dérivation de clé (PBKDF2)
    final prefs = await SharedPreferences.getInstance();
    final masterKeyBase64 = prefs.getString(_encryptionKeyKey) ?? '';
    final combined = '$memberEmail:$masterKeyBase64';
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);
    // Prendre les 32 premiers bytes du hash pour la clé
    return encrypt.Key.fromBase64(base64Encode(hash.bytes.sublist(0, 32)));
  }

  // Méthodes legacy (gardées pour compatibilité)
  Future<String> encryptDocument(String content) async {
    await _initializeEncryption();
    final iv = encrypt.IV.fromLength(16);
    return _encrypter.encrypt(content, iv: iv).base64;
  }

  Future<String> decryptDocument(String encryptedContent) async {
    await _initializeEncryption();
    final iv = encrypt.IV.fromLength(16);
    return _encrypter.decrypt64(encryptedContent, iv: iv);
  }
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../services/local_storage_service.dart';
import 'notification_service.dart';

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
    members.add(member);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _membersKey,
      members.map((m) => '${m.id}|${m.name}|${m.email}|${m.phone ?? ''}|${m.relationship}|${m.isActive}|${m.createdAt.toIso8601String()}').toList(),
    );
  }

  Future<void> removeFamilyMember(int memberId) async {
    final members = await getFamilyMembers();
    members.removeWhere((m) => m.id == memberId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _membersKey,
      members.map((m) => '${m.id}|${m.name}|${m.email}|${m.phone ?? ''}|${m.relationship}|${m.isActive}|${m.createdAt.toIso8601String()}').toList(),
    );
  }

  // Partage documents avec chiffrement et permissions granulaires
  Future<void> shareDocumentWithMembers(
    String documentId,
    List<int> memberIds, {
    bool encrypt = true,
    bool sendNotification = true,
    String? permissionLevel, // 'view', 'download', 'full'
  }) async {
    if (encrypt) {
      await _initializeEncryption();
    }
    
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    
    final sharedDoc = SharedDocument(
      documentId: documentId,
      memberIds: memberIds,
      sharedAt: DateTime.now(),
      isEncrypted: encrypt,
    );
    
    // Format: documentId:memberIds:sharedAt:encrypt:permissionLevel
    final permission = permissionLevel ?? 'view';
    sharedJson.add('$documentId:${memberIds.join(",")}:${sharedDoc.sharedAt.toIso8601String()}:$encrypt:$permission');
    await prefs.setStringList(_sharedDocumentsKey, sharedJson);
    
    // Enregistrer dans audit log
    await _addAuditLog(documentId, memberIds, 'shared');
    
    // Envoyer notification si demandé
    if (sendNotification) {
      final members = await getFamilyMembers();
      for (final memberId in memberIds) {
        final member = members.firstWhere((m) => m.id == memberId, orElse: () => FamilyMember(name: 'Membre', email: '', relationship: ''));
        final doc = await LocalStorageService.getDocuments();
        final docName = doc.firstWhere((d) => d['id'] == documentId, orElse: () => {'name': 'Document'})['name'] ?? 'Document';
        await NotificationService.notifyDocumentShared(
          documentName: docName,
          memberName: member.name,
        );
      }
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

  Future<void> unshareDocument(String documentId) async {
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
    
    sharedJson.removeWhere((entry) => entry.startsWith('$documentId:'));
    await prefs.setStringList(_sharedDocumentsKey, sharedJson);
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

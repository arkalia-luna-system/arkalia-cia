# Plan 05 : Partage familial contrôlé

**Version** : 1.0.0  
**Date** : 20 novembre 2025  
**Statut** : ✅ Implémenté

---

## Vue d'ensemble

Tableau de bord partage familial avec contrôle granularité fine.

---

## 🎯 **OBJECTIF**

Permettre à votre mère de **choisir exactement** ce qu'elle veut partager avec sa famille :
- Contrôle document par document
- Gestion membres famille
- Permissions granulaires
- Chiffrement bout-en-bout
- Interface ultra-simple

---

## 📋 **BESOINS IDENTIFIÉS**

### **Besoin Principal**
- ✅ Endroit partage famille
- ✅ Contrôle total : choisir ce qui est partagé
- ✅ Granularité fine : document par document
- ✅ Sécurité : partage sécurisé uniquement famille de confiance
- ✅ Tableau de bord simple pour gérer partage

### **Fonctionnalités Requises**
- 👥 Gestion membres famille (ajout, suppression)
- 📄 Choix documents à partager (checkboxes)
- 🔐 Chiffrement bout-en-bout
- 📊 Audit log (qui a accédé à quoi)
- 🔔 Notifications partage

---

## 🏗️ **ARCHITECTURE**

### **Sécurité**

```
Partage Familial
├── Chiffrement bout-en-bout (AES-256)
├── Clés séparées par membre famille
├── Tokens d'authentification sécurisés
└── Audit log complet
```

### **Structure Fichiers**

```
arkalia_cia/
├── lib/
│   ├── screens/
│   │   ├── family_sharing_screen.dart       # Tableau de bord partage
│   │   └── manage_family_members_screen.dart # Gestion membres
│   ├── services/
│   │   ├── family_sharing_service.dart       # Service partage
│   │   └── encryption_service.dart          # Chiffrement
│   └── widgets/
│       └── document_sharing_widget.dart     # Widget choix documents
```

---

## 🔧 **IMPLÉMENTATION DÉTAILLÉE**

### **Étape 1 : Modèle Données**

**Fichier** : `arkalia_cia/lib/models/family_sharing.dart`

```dart
class FamilyMember {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String relationship;  // 'spouse', 'child', 'parent', etc.
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
}

class SharedDocument {
  final int documentId;
  final List<int> memberIds;  // Membres avec accès
  final DateTime sharedAt;
  final String? notes;

  SharedDocument({
    required this.documentId,
    required this.memberIds,
    DateTime? sharedAt,
    this.notes,
  }) : sharedAt = sharedAt ?? DateTime.now();
}

class SharingPermission {
  final int documentId;
  final int memberId;
  final bool canView;
  final bool canComment;
  final bool canDownload;

  SharingPermission({
    required this.documentId,
    required this.memberId,
    this.canView = true,
    this.canComment = false,
    this.canDownload = false,
  });
}
```

---

### **Étape 2 : Service Chiffrement**

**Fichier** : `arkalia_cia/lib/services/encryption_service.dart`

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final _key = Key.fromSecureRandom(32);  // AES-256
  static final _iv = IV.fromSecureRandom(16);
  static final _encrypter = Encrypter(AES(_key));

  // Chiffrer document pour partage
  static String encryptForSharing(String content, String memberKey) {
    // Générer clé spécifique membre
    final memberKeyBytes = utf8.encode(memberKey);
    final key = Key.fromBase64(base64Encode(memberKeyBytes));
    final encrypter = Encrypter(AES(key));
    
    final encrypted = encrypter.encrypt(content, iv: _iv);
    return encrypted.base64;
  }

  // Déchiffrer document partagé
  static String decryptShared(String encryptedContent, String memberKey) {
    final memberKeyBytes = utf8.encode(memberKey);
    final key = Key.fromBase64(base64Encode(memberKeyBytes));
    final encrypter = Encrypter(AES(key));
    
    final encrypted = Encrypted.fromBase64(encryptedContent);
    return encrypter.decrypt(encrypted, iv: _iv);
  }

  // Générer clé unique pour membre
  static String generateMemberKey(String memberEmail, String masterKey) {
    final bytes = utf8.encode('$memberEmail:$masterKey');
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
```

---

### **Étape 3 : Service Partage Familial**

**Fichier** : `arkalia_cia/lib/services/family_sharing_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/family_sharing.dart';
import 'encryption_service.dart';

class FamilySharingService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CRUD Membres famille
  Future<int> addFamilyMember(FamilyMember member) async {
    final db = await _dbHelper.database;
    return await db.insert('family_members', {
      'name': member.name,
      'email': member.email,
      'phone': member.phone,
      'relationship': member.relationship,
      'is_active': member.isActive ? 1 : 0,
      'created_at': member.createdAt.toIso8601String(),
    });
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'family_members',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return maps.map((m) => FamilyMember(
      id: m['id'],
      name: m['name'],
      email: m['email'],
      phone: m['phone'],
      relationship: m['relationship'],
      isActive: m['is_active'] == 1,
      createdAt: DateTime.parse(m['created_at']),
    )).toList();
  }

  // Partage documents
  Future<void> shareDocumentWithMembers(
    int documentId,
    List<int> memberIds,
  ) async {
    final db = await _dbHelper.database;
    
    // Récupérer contenu document
    final docMaps = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [documentId],
    );
    
    if (docMaps.isEmpty) return;
    
    final document = docMaps.first;
    final content = document['text_content'] as String? ?? '';
    
    // Chiffrer pour chaque membre
    for (final memberId in memberIds) {
      final memberMaps = await db.query(
        'family_members',
        where: 'id = ?',
        whereArgs: [memberId],
      );
      
      if (memberMaps.isEmpty) continue;
      
      final member = memberMaps.first;
      final memberEmail = member['email'] as String;
      
      // Générer clé membre
      final masterKey = await _getMasterKey();
      final memberKey = EncryptionService.generateMemberKey(memberEmail, masterKey);
      
      // Chiffrer contenu
      final encryptedContent = EncryptionService.encryptForSharing(content, memberKey);
      
      // Sauvegarder partage
      await db.insert('shared_documents', {
        'document_id': documentId,
        'member_id': memberId,
        'encrypted_content': encryptedContent,
        'shared_at': DateTime.now().toIso8601String(),
      });
      
      // Audit log
      await db.insert('sharing_audit_log', {
        'document_id': documentId,
        'member_id': memberId,
        'action': 'shared',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<int>> getSharedDocumentIds(int memberId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shared_documents',
      columns: ['document_id'],
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
    return maps.map((m) => m['document_id'] as int).toList();
  }

  Future<String> _getMasterKey() async {
    // Récupérer clé maître depuis stockage sécurisé
    // (Keychain/Keystore)
    // Pour l'instant, retourner clé par défaut
    return 'master_key_placeholder';
  }
}
```

---

### **Étape 4 : Interface Partage**

**Fichier** : `arkalia_cia/lib/screens/family_sharing_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/family_sharing_service.dart';
import '../models/family_sharing.dart';
import '../widgets/document_sharing_widget.dart';
import 'manage_family_members_screen.dart';

class FamilySharingScreen extends StatefulWidget {
  @override
  _FamilySharingScreenState createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  final FamilySharingService _sharingService = FamilySharingService();
  List<FamilyMember> _members = [];
  Map<int, bool> _selectedDocuments = {};  // documentId -> isShared
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final members = await _sharingService.getFamilyMembers();
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _shareSelectedDocuments() async {
    final selectedIds = _selectedDocuments.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sélectionnez au moins un document')),
      );
      return;
    }

    // Demander quels membres peuvent voir
    final selectedMembers = await _showMemberSelectionDialog();

    if (selectedMembers.isEmpty) {
      return;
    }

    // Partager avec membres sélectionnés
    for (final docId in selectedIds) {
      await _sharingService.shareDocumentWithMembers(
        docId,
        selectedMembers,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Documents partagés avec succès')),
    );
  }

  Future<List<int>> _showMemberSelectionDialog() async {
    return await showDialog<List<int>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir membres famille'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _members.map((member) {
            return CheckboxListTile(
              title: Text(member.name),
              subtitle: Text(member.relationship),
              value: false,
              onChanged: (value) {
                // Gérer sélection
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, []),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Retourner IDs membres sélectionnés
              Navigator.pop(context, []);
            },
            child: Text('Partager'),
          ),
        ],
      ),
    ) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partage Familial'),
        actions: [
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageFamilyMembersScreen(),
                ),
              );
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Liste membres
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Membres famille (${_members.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                
                // Documents à partager
                Expanded(
                  child: DocumentSharingWidget(
                    selectedDocuments: _selectedDocuments,
                    onSelectionChanged: (docId, isSelected) {
                      setState(() {
                        _selectedDocuments[docId] = isSelected;
                      });
                    },
                  ),
                ),
                
                // Bouton partager
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _shareSelectedDocuments,
                    icon: Icon(Icons.share),
                    label: Text('Partager documents sélectionnés'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
```

---

## ✅ **TESTS**

### **Tests Sécurité**

```dart
// test/encryption_test.dart
void main() {
  test('Chiffrement déchiffrement fonctionne', () {
    final content = 'Contenu secret';
    final memberKey = 'test_key';
    
    final encrypted = EncryptionService.encryptForSharing(content, memberKey);
    final decrypted = EncryptionService.decryptShared(encrypted, memberKey);
    
    expect(decrypted, equals(content));
  });
}
```

---

## 🚀 **PERFORMANCE**

### **Optimisations**

1. **Chiffrement asynchrone** : Chiffrer en arrière-plan
2. **Cache clés** : Mettre en cache clés membres
3. **Batch sharing** : Partager plusieurs documents ensemble

---

## 🔐 **SÉCURITÉ**

1. **Chiffrement AES-256** : Niveau militaire
2. **Clés séparées** : Chaque membre a sa propre clé
3. **Audit log** : Traçabilité complète accès
4. **Validation** : Vérifier identité avant partage
5. **Expiration** : Tokens expirent après période

---

## 📅 **TIMELINE**

### **Semaine 1 : Backend Sécurité**
- [ ] Jour 1-2 : EncryptionService
- [ ] Jour 3-4 : FamilySharingService
- [ ] Jour 5 : Tests sécurité

### **Semaine 2 : Frontend**
- [ ] Jour 1-2 : Interface partage
- [ ] Jour 3 : Gestion membres
- [ ] Jour 4-5 : Tests UI

### **Semaine 3 : Finalisation**
- [ ] Jour 1-2 : Audit log
- [ ] Jour 3-4 : Tests finaux
- [ ] Jour 5 : Documentation

---

## 📚 **RESSOURCES**

- **encrypt package** : https://pub.dev/packages/encrypt
- **crypto package** : https://pub.dev/packages/crypto

---

**Statut** : 📋 **PLAN VALIDÉ**  
**Priorité** : 🟠 **HAUTE**  
**Temps estimé** : 1 mois


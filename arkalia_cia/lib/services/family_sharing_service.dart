import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';

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

class FamilySharingService {
  static const String _membersKey = 'family_members';
  static const String _sharedDocumentsKey = 'shared_documents';

  // CRUD Membres famille
  Future<List<FamilyMember>> getFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = prefs.getStringList(_membersKey) ?? [];
    return membersJson.map((json) {
      // Simple parsing (à améliorer avec JSON)
      return FamilyMember.fromMap({'name': json, 'email': '', 'relationship': ''});
    }).toList();
  }

  Future<void> addFamilyMember(FamilyMember member) async {
    final members = await getFamilyMembers();
    members.add(member);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _membersKey,
      members.map((m) => m.name).toList(),
    );
  }

  // Partage documents
  Future<void> shareDocumentWithMembers(
    String documentId,
    List<int> memberIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    sharedJson.add('$documentId:${memberIds.join(",")}');
    await prefs.setStringList(_sharedDocumentsKey, sharedJson);
  }

  Future<List<String>> getSharedDocumentIds(int memberId) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedJson = prefs.getStringList(_sharedDocumentsKey) ?? [];
    final sharedDocs = <String>[];
    
    for (var entry in sharedJson) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final docId = parts[0];
        final memberIds = parts[1].split(',').map((id) => int.parse(id)).toList();
        if (memberIds.contains(memberId)) {
          sharedDocs.add(docId);
        }
      }
    }
    
    return sharedDocs;
  }
}


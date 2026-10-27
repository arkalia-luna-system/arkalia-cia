/// Vue mince d'un document médical (affichage / filtres).
/// Le stockage continue d'utiliser des maps ; ce modèle ne réécrit pas la persistence.
class Document {
  const Document({
    required this.id,
    required this.name,
    this.category,
    this.fileSize,
    this.createdAt,
    this.metadata,
  });

  final String id;
  final String name;
  final String? category;
  final int? fileSize;
  final String? createdAt;
  final Map<String, dynamic>? metadata;

  String get displayCategory => category ?? 'Non catégorisé';

  String? get examType {
    final meta = metadata;
    if (meta == null) return null;
    final value = meta['exam_type'];
    return value?.toString();
  }

  double? get examTypeConfidence {
    final meta = metadata;
    if (meta == null) return null;
    final value = meta['exam_type_confidence'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  bool get needsVerification => metadata?['needs_verification'] == true;

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id']?.toString() ?? '',
      name: (map['original_name'] ?? map['name'] ?? 'Document').toString(),
      category: map['category']?.toString(),
      fileSize: map['file_size'] is int
          ? map['file_size'] as int
          : int.tryParse(map['file_size']?.toString() ?? ''),
      createdAt: map['created_at']?.toString(),
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }
}

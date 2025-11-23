/// Modèle représentant une entrée de suivi pour une pathologie
class PathologyTracking {
  final int? id;
  final int pathologyId;
  final DateTime date;
  final Map<String, dynamic> data; // Symptômes, mesures, douleurs, etc.
  final String? notes;
  final DateTime createdAt;

  PathologyTracking({
    this.id,
    required this.pathologyId,
    required this.date,
    Map<String, dynamic>? data,
    this.notes,
    DateTime? createdAt,
  }) : data = data ?? {},
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pathology_id': pathologyId,
      'date': date.toIso8601String(),
      'data': data,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PathologyTracking.fromMap(Map<String, dynamic> map) {
    return PathologyTracking(
      id: map['id'],
      pathologyId: map['pathology_id'],
      date: DateTime.parse(map['date']),
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'])
          : {},
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  PathologyTracking copyWith({
    int? id,
    int? pathologyId,
    DateTime? date,
    Map<String, dynamic>? data,
    String? notes,
    DateTime? createdAt,
  }) {
    return PathologyTracking(
      id: id ?? this.id,
      pathologyId: pathologyId ?? this.pathologyId,
      date: date ?? this.date,
      data: data ?? this.data,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


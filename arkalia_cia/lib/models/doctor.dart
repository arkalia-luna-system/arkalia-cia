class Doctor {
  final int? id;
  final String firstName;
  final String lastName;
  final String? specialty;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? postalCode;
  final String country;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    this.id,
    required this.firstName,
    required this.lastName,
    this.specialty,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.postalCode,
    this.country = 'Belgique',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'specialty': specialty,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      specialty: map['specialty'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      city: map['city'],
      postalCode: map['postal_code'],
      country: map['country'] ?? 'Belgique',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Doctor copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? specialty,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Consultation {
  final int? id;
  final int doctorId;
  final DateTime date;
  final String? reason;
  final String? notes;
  final List<int> documentIds;
  final DateTime createdAt;

  Consultation({
    this.id,
    required this.doctorId,
    required this.date,
    this.reason,
    this.notes,
    List<int>? documentIds,
    DateTime? createdAt,
  }) : documentIds = documentIds ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'date': date.toIso8601String(),
      'reason': reason,
      'notes': notes,
      'documents': documentIds.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'],
      doctorId: map['doctor_id'],
      date: DateTime.parse(map['date']),
      reason: map['reason'],
      notes: map['notes'],
      documentIds: map['documents'] != null
          ? (map['documents'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => int.parse(s))
              .toList()
          : [],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}


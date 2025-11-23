/// Modèle représentant une entrée d'hydratation
class HydrationEntry {
  final int? id;
  final DateTime date;
  final int amount; // en millilitres
  final DateTime time;

  HydrationEntry({
    this.id,
    required this.date,
    required this.amount,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Date seulement
      'amount': amount,
      'time': time.toIso8601String(),
    };
  }

  factory HydrationEntry.fromMap(Map<String, dynamic> map) {
    return HydrationEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'] ?? 0,
      time: DateTime.parse(map['time']),
    );
  }

  HydrationEntry copyWith({
    int? id,
    DateTime? date,
    int? amount,
    DateTime? time,
  }) {
    return HydrationEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      time: time ?? this.time,
    );
  }
}

/// Modèle représentant l'objectif d'hydratation quotidien
class HydrationGoal {
  final int? id;
  final int dailyGoal; // en millilitres, default 2000ml = 8 verres de 250ml
  final DateTime updatedAt;

  HydrationGoal({
    this.id,
    this.dailyGoal = 2000,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Retourne le nombre de verres équivalent (1 verre = 250ml)
  int get glasses => (dailyGoal / 250).round();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_goal': dailyGoal,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory HydrationGoal.fromMap(Map<String, dynamic> map) {
    return HydrationGoal(
      id: map['id'],
      dailyGoal: map['daily_goal'] ?? 2000,
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  HydrationGoal copyWith({
    int? id,
    int? dailyGoal,
    DateTime? updatedAt,
  }) {
    return HydrationGoal(
      id: id ?? this.id,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


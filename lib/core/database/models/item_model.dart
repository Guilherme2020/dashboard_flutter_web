class ItemModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double value;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      value: (map['value'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      status: map['status'] as String,
    );
  }

  ItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? value,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}


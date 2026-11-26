import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    this.ownerName = '',
    this.category,
    this.capacity,
    this.technologies = const [],
    this.neededRoles = const [],
    this.status = statusOpen,
    this.memberIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Firestore'da saklanan ve arayüzde kullanılan durum değerleri
  static const String statusOpen = 'open';
  static const String statusClosed = 'closed';
  static const String statusCompleted = 'completed';
  static const String statusFull = 'full';

  static const List<String> categories = [
    'Mobil',
    'Web',
    'Yapay Zeka',
    'Veri Bilimi',
    'Oyun',
    'Siber Güvenlik',
    'Diğer',
  ];

  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final String? category;
  final int? capacity;
  final List<String> technologies;
  final List<String> neededRoles;
  final String status; // open, closed, completed
  final List<String> memberIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOpen => status == statusOpen;

  bool get isCompleted => status == statusCompleted;

  bool get isFull =>
      capacity != null && capacity! > 0 && memberIds.length >= capacity!;

  bool get canApply => isOpen && !isFull;

  int? get remainingSlots {
    if (capacity == null || capacity! <= 0) return null;
    final remaining = capacity! - memberIds.length;
    return remaining < 0 ? 0 : remaining;
  }

  /// Kontenjan doluysa UI gösterimi için `full` durumunu döndürür.
  String get effectiveStatus {
    if (status == statusCompleted) return statusCompleted;
    if (status == statusClosed) return statusClosed;
    if (isFull) return statusFull;
    return statusOpen;
  }

  bool isOwner(String? uid) => uid != null && uid == ownerId;

  bool isMember(String? uid) => uid != null && memberIds.contains(uid);

  // Firestore'dan gelen JSON haritası Project nesnesine dönüştürüldü
  factory Project.fromMap(Map<String, dynamic> data, String id) {
    final rawCategory = data['category'] as String?;
    return Project(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      category:
          rawCategory != null && rawCategory.trim().isNotEmpty ? rawCategory.trim() : null,
      capacity: (data['capacity'] as num?)?.toInt(),
      technologies: _stringList(data['technologies']),
      neededRoles: _stringList(data['neededRoles']),
      status: data['status'] as String? ?? statusOpen,
      memberIds: _stringList(data['memberIds']),
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  // Zaman damgaları servis katmanında serverTimestamp ile eklenir
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      if (category != null && category!.trim().isNotEmpty) 'category': category!.trim(),
      if (capacity != null && capacity! > 0) 'capacity': capacity,
      'technologies': technologies,
      'neededRoles': neededRoles,
      'status': status,
      'memberIds': memberIds,
    };
  }

  Project copyWith({
    String? title,
    String? description,
    String? category,
    int? capacity,
    bool clearCapacity = false,
    List<String>? technologies,
    List<String>? neededRoles,
    String? status,
    List<String>? memberIds,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId,
      ownerName: ownerName,
      category: category ?? this.category,
      capacity: clearCapacity ? null : (capacity ?? this.capacity),
      technologies: technologies ?? this.technologies,
      neededRoles: neededRoles ?? this.neededRoles,
      status: status ?? this.status,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

List<String> _stringList(Object? value) =>
    (value as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];

DateTime? _toDate(Object? value) => value is Timestamp ? value.toDate() : null;

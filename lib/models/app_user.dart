import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String? bio;
  final String? department;
  final List<String> skills;
  final String? githubUrl;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.id,
    required this.name,
    this.bio,
    this.department,
    this.skills = const [],
    this.githubUrl,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Firestore dokümanından [AppUser] nesnesi oluşturur.
  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] as String? ?? '',
      bio: data['bio'] as String?,
      department: data['department'] as String?,
      skills: (data['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      githubUrl: data['githubUrl'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  /// Firestore `users/{uid}` belgesine yazılacak alanları döndürür.
  /// E-posta Firebase Authentication'da tutulduğu için burada yer almaz.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (bio != null) 'bio': bio,
      if (department != null) 'department': department,
      'skills': skills,
      if (githubUrl != null) 'githubUrl': githubUrl,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Seçili alanları güncellenmiş yeni bir [AppUser] kopyası döndürür.
  AppUser copyWith({
    String? name,
    String? bio,
    String? department,
    List<String>? skills,
    String? githubUrl,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      department: department ?? this.department,
      skills: skills ?? this.skills,
      githubUrl: githubUrl ?? this.githubUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

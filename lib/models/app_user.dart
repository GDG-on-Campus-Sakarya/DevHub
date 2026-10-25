class AppUser {
  final String id;
  final String name;
  final String? email;
  final String? bio;
  final String? department;
  final List<String> skills;
  final String? githubUrl;

  const AppUser({
    required this.id,
    required this.name,
    this.email,
    this.bio,
    this.department,
    this.skills = const [],
    this.githubUrl,
  });

  // Firestore'dan gelen JSON haritası AppUser nesnesine dönüştürüldü
  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String?,
      bio: data['bio'] as String?,
      department: data['department'] as String?,
      skills: (data['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      githubUrl: data['githubUrl'] as String?,
    );
  }

  // AppUser nesnesi Firestore'a yazılacak JSON haritasına dönüştürüldü
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (email != null) 'email': email,
      if (bio != null) 'bio': bio,
      if (department != null) 'department': department,
      'skills': skills,
      if (githubUrl != null) 'githubUrl': githubUrl,
    };
  }

  // Alanları güncellenmiş yeni bir nesne kopyası oluşturuldu
  AppUser copyWith({
    String? name,
    String? email,
    String? bio,
    String? department,
    List<String>? skills,
    String? githubUrl,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      department: department ?? this.department,
      skills: skills ?? this.skills,
      githubUrl: githubUrl ?? this.githubUrl,
    );
  }
}

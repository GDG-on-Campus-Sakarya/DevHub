class AppUser {
  const AppUser({required this.id, required this.name, this.department, this.skills = const [], this.githubUrl});
  final String id;
  final String name;
  final String? department;
  final List<String> skills;
  final String? githubUrl;
}

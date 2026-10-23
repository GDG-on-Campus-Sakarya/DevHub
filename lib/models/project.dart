class Project {
  const Project({required this.id, required this.title, required this.description, required this.ownerId, this.technologies = const [], this.neededRoles = const []});
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final List<String> technologies;
  final List<String> neededRoles;
}

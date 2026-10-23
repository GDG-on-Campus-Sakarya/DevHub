class ProjectApplication {
  const ProjectApplication({required this.id, required this.projectId, required this.applicantId, this.message = '', this.status = 'pending'});
  final String id;
  final String projectId;
  final String applicantId;
  final String message;
  final String status; // pending, accepted, rejected
}

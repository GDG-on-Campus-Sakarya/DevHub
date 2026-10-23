import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(title: Text(project.title), subtitle: Text(project.description)),
  );
}

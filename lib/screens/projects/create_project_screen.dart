import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key, this.project});

  final Project? project;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _technologies = TextEditingController();
  final _roles = TextEditingController();
  final _service = ProjectService();

  bool _saving = false;
  String _status = Project.statusOpen;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    if (project != null) {
      _title.text = project.title;
      _description.text = project.description;
      _technologies.text = project.technologies.join(', ');
      _roles.text = project.neededRoles.join(', ');
      _status = project.status;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _technologies.dispose();
    _roles.dispose();
    super.dispose();
  }

  List<String> _parseList(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final project = widget.project;
      if (project == null) {
        await _service.createProject(
          title: _title.text,
          description: _description.text,
          technologies: _parseList(_technologies.text),
          neededRoles: _parseList(_roles.text),
          status: _status,
        );
      } else {
        await _service.updateProject(
          project.copyWith(
            title: _title.text.trim(),
            description: _description.text.trim(),
            technologies: _parseList(_technologies.text),
            neededRoles: _parseList(_roles.text),
            status: _status,
          ),
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'Proje oluştur' : 'Projeyi düzenle'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _title,
                        maxLength: 100,
                        decoration: const InputDecoration(labelText: 'Proje adı'),
                        validator: (value) => value == null || value.trim().length < 3
                            ? 'En az 3 karakter gir.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _description,
                        minLines: 4,
                        maxLines: 7,
                        maxLength: 2000,
                        decoration: const InputDecoration(labelText: 'Proje açıklaması'),
                        validator: (value) => value == null || value.trim().length < 10
                            ? 'Açıklama en az 10 karakter olmalı.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _technologies,
                        decoration: const InputDecoration(
                          labelText: 'Teknolojiler',
                          hintText: 'Flutter, Firebase, Dart',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _roles,
                        decoration: const InputDecoration(
                          labelText: 'Aranan roller',
                          hintText: 'Frontend, UI/UX, Backend',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Başvuru durumu'),
                        items: const [
                          DropdownMenuItem(
                            value: Project.statusOpen,
                            child: Text('Açık - ekip arkadaşı aranıyor'),
                          ),
                          DropdownMenuItem(
                            value: Project.statusClosed,
                            child: Text('Kapalı'),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => _status = value ?? Project.statusOpen,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Kaydet'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

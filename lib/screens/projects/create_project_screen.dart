import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key, this.project, this.service});

  final Project? project;
  final ProjectService? service;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _technologies = TextEditingController();
  final _roles = TextEditingController();
  final _capacity = TextEditingController();
  late final ProjectService _service = widget.service ?? ProjectService();

  bool _saving = false;
  String _status = Project.statusOpen;
  String _category = Project.categories.first;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    if (project != null) {
      _title.text = project.title;
      _description.text = project.description;
      _technologies.text = project.technologies.join(', ');
      _roles.text = project.neededRoles.join(', ');
      if (project.capacity != null && project.capacity! > 0) {
        _capacity.text = project.capacity.toString();
      }
      _status = project.status;
      if (project.category != null &&
          Project.categories.contains(project.category)) {
        _category = project.category!;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _technologies.dispose();
    _roles.dispose();
    _capacity.dispose();
    super.dispose();
  }

  List<String> _parseList(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();

  int? _parseCapacity() {
    final text = _capacity.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final project = widget.project;
      final capacity = _parseCapacity();
      if (project == null) {
        await _service.createProject(
          title: _title.text,
          description: _description.text,
          technologies: _parseList(_technologies.text),
          neededRoles: _parseList(_roles.text),
          category: _category,
          capacity: capacity,
          status: _status,
        );
      } else {
        await _service.updateProject(
          project.copyWith(
            title: _title.text.trim(),
            description: _description.text.trim(),
            technologies: _parseList(_technologies.text),
            neededRoles: _parseList(_roles.text),
            category: _category,
            capacity: capacity,
            clearCapacity: capacity == null,
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
    final project = widget.project;
    final isEditing = project != null;
    final minCapacity = isEditing ? project.memberIds.length : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Projeyi düzenle' : 'Proje oluştur'),
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
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: [
                          for (final cat in Project.categories)
                            DropdownMenuItem(value: cat, child: Text(cat)),
                        ],
                        onChanged: (value) => setState(
                          () => _category = value ?? Project.categories.first,
                        ),
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
                      TextFormField(
                        controller: _capacity,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Ekip kontenjanı (isteğe bağlı)',
                          hintText: 'Örn: 5',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return null;
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed < 1) {
                            return 'Kontenjan en az 1 olmalıdır.';
                          }
                          if (parsed < minCapacity) {
                            return 'Kontenjan mevcut üye sayısından ($minCapacity) az olamaz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Proje durumu'),
                        items: const [
                          DropdownMenuItem(
                            value: Project.statusOpen,
                            child: Text('Açık - ekip arkadaşı aranıyor'),
                          ),
                          DropdownMenuItem(
                            value: Project.statusClosed,
                            child: Text('Kapalı - başvurular durduruldu'),
                          ),
                          DropdownMenuItem(
                            value: Project.statusCompleted,
                            child: Text('Tamamlandı'),
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

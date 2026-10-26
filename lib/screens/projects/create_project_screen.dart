import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';

/// Proje oluşturma ekranı. [project] verilirse aynı form düzenleme için açılır.
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key, this.project});
  final Project? project;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  // Tasarımdaki seçenek listeleri
  static const List<String> _technologyOptions = [
    'C#', '.NET', 'Java', 'Python', 'JavaScript', 'TypeScript', 'Flutter', 'Dart', 'React',
    'Node.js', 'SQL', 'Firebase', 'PostgreSQL', 'Figma', 'Docker', 'Git',
  ];
  static const List<String> _roleOptions = [
    'Backend Geliştirici', 'Frontend Geliştirici', 'Full-Stack Geliştirici', 'Flutter Geliştirici',
    'Mobil Geliştirici', 'UI/UX Tasarımcısı', 'Veri Analisti', 'Yapay Zekâ/ML Mühendisi',
    'DevOps Mühendisi', 'QA / Test Mühendisi',
  ];

  final _service = ProjectService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.project?.title ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.project?.description ?? '');
  late String _status = widget.project?.status ?? Project.statusOpen;
  late final Set<String> _technologies = {...?widget.project?.technologies};
  late final Set<String> _roles = {...?widget.project?.neededRoles};

  bool _saving = false;
  bool _showChipErrors = false;
  String? _error;

  bool get _isEdit => widget.project != null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    setState(() => _showChipErrors = true);
    if (!formValid || _technologies.isEmpty || _roles.isEmpty) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_isEdit) {
        await _service.updateProject(widget.project!.copyWith(
          title: _title.text,
          description: _description.text,
          technologies: _technologies.toList(),
          neededRoles: _roles.toList(),
          status: _status,
        ));
      } else {
        await _service.createProject(
          title: _title.text,
          description: _description.text,
          technologies: _technologies.toList(),
          neededRoles: _roles.toList(),
          status: _status,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Proje güncellendi.' : 'Proje oluşturuldu.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Projeyi düzenle' : 'Proje oluştur';

    // Arayüzdeki erken kontrol; asıl yetki denetimi Firestore kurallarında
    String? blocked;
    if (!_service.canContribute) {
      blocked = 'Proje oluşturmak için misafir olarak değil, hesabınla giriş yapmalısın.';
    } else if (_isEdit && !widget.project!.isOwner(_service.currentUserId)) {
      blocked = 'Yalnızca proje sahibi bu projeyi düzenleyebilir.';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: blocked != null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(blocked)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildForm(context, title),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildForm(BuildContext context, String title) {
    final theme = Theme.of(context);
    final errorStyle = TextStyle(color: theme.colorScheme.error, fontSize: 12);
    final hintStyle = theme.textTheme.bodySmall;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isEdit ? 'PROJEYİ GÜNCELLE' : 'YENİ PROJE',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.primary, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Fikrini paylaş ve doğru ekip arkadaşlarını bul.', style: hintStyle),
          const SizedBox(height: 24),
          _label(context, 'Proje adı'),
          TextFormField(
            controller: _title,
            enabled: !_saving,
            maxLength: 100,
            decoration: const InputDecoration(hintText: 'örn. Campus Connect', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().length < 3)
                ? 'Proje adı en az 3 karakter olmalı.'
                : null,
          ),
          const SizedBox(height: 8),
          _label(context, 'Açıklama'),
          TextFormField(
            controller: _description,
            enabled: !_saving,
            maxLines: 5,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'Ne geliştiriyorsun ve neden önemli?',
              helperText: 'Problemi ve hedeflerini açıkça anlat.',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().length < 10)
                ? 'Açıklama en az 10 karakter olmalı.'
                : null,
          ),
          const SizedBox(height: 8),
          _label(context, 'Proje durumu'),
          SizedBox(
            width: 320,
            child: DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: Project.statusOpen, child: Text('Başvurulara açık')),
                DropdownMenuItem(value: Project.statusClosed, child: Text('Başvurulara kapalı')),
              ],
              onChanged: _saving ? null : (v) => setState(() => _status = v ?? _status),
            ),
          ),
          const SizedBox(height: 20),
          _label(context, 'Teknolojiler'),
          _chips({..._technologyOptions, ..._technologies}.toList(), _technologies),
          const SizedBox(height: 6),
          _showChipErrors && _technologies.isEmpty
              ? Text('En az bir teknoloji seç.', style: errorStyle)
              : Text('Projede kullanılan bir veya daha fazla teknolojiyi seç.', style: hintStyle),
          const SizedBox(height: 20),
          _label(context, 'Aranan roller'),
          _chips({..._roleOptions, ..._roles}.toList(), _roles),
          const SizedBox(height: 6),
          _showChipErrors && _roles.isEmpty
              ? Text('En az bir rol seç.', style: errorStyle)
              : Text('Proje için aranan bir veya daha fazla rolü seç.', style: hintStyle),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEdit ? 'Değişiklikleri kaydet' : 'Proje oluştur'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _chips(List<String> options, Set<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: _saving
                ? null
                : (on) => setState(() => on ? selected.add(option) : selected.remove(option)),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';

/// "Başvur: [proje adı]" modalı. Başvuru gönderilirse true döner.
Future<bool?> showApplyDialog(BuildContext context, Project project) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _ApplyDialog(project: project),
  );
}

class _ApplyDialog extends StatefulWidget {
  const _ApplyDialog({required this.project});
  final Project project;

  @override
  State<_ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<_ApplyDialog> {
  static const int _maxLength = 500;

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ProjectService().applyToProject(widget.project, _messageController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başvurun gönderildi. Durumu "Başvurularım" sayfasından takip edebilirsin.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BAŞVURU',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary, letterSpacing: 1.2)),
                          const SizedBox(height: 6),
                          Text('Başvur: ${widget.project.title}',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Neden iyi bir ekip arkadaşı olacağını anlat.',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kapat',
                      onPressed: _submitting ? null : () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Mesajın', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  maxLength: _maxLength,
                  enabled: !_submitting,
                  decoration: const InputDecoration(
                    hintText: 'İlgini, deneyimini ve projeye nasıl katkı sağlayabileceğini paylaş...',
                    helperText: '50–500 karakter önerilir',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir başvuru mesajı yaz.';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Başvuruyu gönder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

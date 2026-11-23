import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';

Future<void> showApplyDialog(BuildContext context, Project project) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final service = ProjectService();
  await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
    title: Text('${project.title} projesine başvur'),
    content: Form(key: formKey, child: TextFormField(controller: controller, minLines: 3, maxLines: 6, maxLength: 500, decoration: const InputDecoration(labelText: 'Başvuru mesajı', hintText: 'Bu projeye nasıl katkı sağlayabilirsin?'), validator: (v) => v == null || v.trim().isEmpty ? 'Bir mesaj yazmalısın.' : null)),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Vazgeç')), FilledButton(onPressed: () async {
      if (!formKey.currentState!.validate()) return;
      try {
        await service.applyToProject(project, controller.text);
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Başvurun gönderildi.')));
      } catch (e) {
        if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(dialogContext).colorScheme.error));
      }
    }, child: const Text('Başvuruyu gönder'))],
  ));
  controller.dispose();
}

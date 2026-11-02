import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  // Profil düzenleme penceresi açıldı ve güncellenen veriler kaydedildi
  Future<void> _showEditProfileDialog(
      BuildContext context, AppUser currentUser) async {
    final nameController = TextEditingController(text: currentUser.name);
    final departmentController =
        TextEditingController(text: currentUser.department ?? '');
    final bioController = TextEditingController(text: currentUser.bio ?? '');
    final skillsController =
        TextEditingController(text: currentUser.skills.join(', '));
    final githubController =
        TextEditingController(text: currentUser.githubUrl ?? '');

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 8.0,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.0,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Profili Düzenle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ad soyad zorunludur'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Bölüm / Departman',
                          hintText: 'Örn: Bilgisayar Mühendisliği',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Biyografi',
                          hintText: 'Kendinizi kısaca tanıtın...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: skillsController,
                        decoration: const InputDecoration(
                          labelText: 'Teknolojiler (Virgülle ayırın)',
                          hintText: 'Flutter, Dart, Firebase, Python',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: githubController,
                        decoration: const InputDecoration(
                          labelText: 'GitHub Profili',
                          hintText: 'https://github.com/kullaniciadi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => isSaving = true);

                                final updatedSkills = skillsController.text
                                    .split(',')
                                    .map((s) => s.trim())
                                    .where((s) => s.isNotEmpty)
                                    .toList();

                                final updatedUser = currentUser.copyWith(
                                  name: nameController.text.trim(),
                                  department: departmentController.text.trim(),
                                  bio: bioController.text.trim(),
                                  skills: updatedSkills,
                                  githubUrl: githubController.text.trim(),
                                );

                                try {
                                  // Güncel profil verisi Firestore'a yazıldı
                                  await _firestoreService
                                      .saveUserProfile(updatedUser);

                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Profil başarıyla güncellendi!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (sheetContext.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Kayıt hatası: ${e.toString()}'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                } finally {
                                  setSheetState(() => isSaving = false);
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Kaydet'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    departmentController.dispose();
    bioController.dispose();
    skillsController.dispose();
    githubController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = _authService.currentUser;

    if (authUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(
          child: Text('Lütfen profilinizi görüntülemek için giriş yapınız.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: StreamBuilder<AppUser?>(
        // Firestore üzerindeki kullanıcı dokümanı anlık dinlendi
        stream: _firestoreService.streamUserProfile(authUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Firestore'da henüz kayıt yoksa temel auth bilgileriyle nesne oluşturuldu
          final user = snapshot.data ??
              AppUser(
                id: authUser.uid,
                name: authUser.displayName ?? 'İsimsiz Kullanıcı',
                email: authUser.email,
              );

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profil başlık kartı
                    Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? authUser.email ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (user.department != null &&
                                user.department!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                user.department!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Biyografi bölümü
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hakkında',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (user.bio != null && user.bio!.isNotEmpty)
                                  ? user.bio!
                                  : 'Henüz bir biyografi eklenmedi.',
                              style: TextStyle(
                                color: (user.bio != null && user.bio!.isNotEmpty)
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Yetenekler ve teknolojiler bölümü
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Teknolojiler & Yetenekler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (user.skills.isEmpty)
                              const Text(
                                'Henüz teknoloji bilgisi eklenmedi.',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: user.skills
                                    .map(
                                      (skill) => Chip(
                                        label: Text(skill),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // GitHub bağlantısı (varsa)
                    if (user.githubUrl != null &&
                        user.githubUrl!.isNotEmpty) ...[
                      Card(
                        elevation: 0,
                        child: ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text('GitHub Profili'),
                          subtitle: Text(user.githubUrl!),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Profili düzenle butonu
                    FilledButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Profili Düzenle'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _showEditProfileDialog(context, user),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

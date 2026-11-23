import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _department = TextEditingController();
  final _skills = TextEditingController();
  final _github = TextEditingController();
  bool _dirty = false;
  bool _saving = false;
  String? _initializedUid;
  String? _profileHydratedUid;

  @override
  void dispose() { _name.dispose(); _bio.dispose(); _department.dispose(); _skills.dispose(); _github.dispose(); super.dispose(); }

  void _populate(AppUser? profile, User user) {
    if (_dirty || _profileHydratedUid == user.uid) return;

    if (_initializedUid != user.uid) {
      _initializedUid = user.uid;
      _name.text = user.displayName ?? '';
      _bio.clear();
      _department.clear();
      _skills.clear();
      _github.clear();
    }

    // Firestore can first emit a missing document and then the newly-created
    // profile. Only mark the profile hydrated after receiving a real document.
    if (profile == null) return;
    _profileHydratedUid = user.uid;
    _name.text = profile.name.isNotEmpty ? profile.name : user.displayName ?? '';
    _bio.text = profile.bio ?? '';
    _department.text = profile.department ?? '';
    _skills.text = profile.skills.join(', ');
    _github.text = profile.githubUrl ?? '';
  }

  void _markDirty(String _) {
    _dirty = true;
  }

  Future<void> _save(User user) async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 100) { _message('Ad alanı 1-100 karakter olmalıdır.', error: true); return; }
    setState(() => _saving = true);
    try {
      await _auth.updateProfile(AppUser(
        id: user.uid,
        name: name,
        email: user.email,
        bio: _bio.text.trim(),
        department: _department.text.trim(),
        skills: _skills.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList(),
        githubUrl: _github.text.trim(),
      ));
      if (mounted) {
        _dirty = false;
        _profileHydratedUid = user.uid;
        _message('Profilin kaydedildi.');
      }
    } catch (e) { if (mounted) _message(e.toString(), error: true); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  void _message(String value, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), backgroundColor: error ? Theme.of(context).colorScheme.error : null));

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Profil için giriş yapmalısın.')));
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim'), actions: [TextButton.icon(onPressed: () async { await _auth.signOut(); if (mounted) Navigator.of(context).popUntil((r) => r.isFirst); }, icon: const Icon(Icons.logout), label: const Text('Çıkış'))]),
      body: StreamBuilder<AppUser?>(
        stream: _firestore.streamUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Profil alınamadı: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          _populate(snapshot.data, user);
          return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CircleAvatar(radius: 34, child: Text((_name.text.trim().isEmpty ? 'D' : _name.text.trim()[0]).toUpperCase(), style: const TextStyle(fontSize: 24))),
            const SizedBox(height: 12), Text(user.email ?? '', textAlign: TextAlign.center), const SizedBox(height: 24),
            TextField(controller: _name, onChanged: _markDirty, decoration: const InputDecoration(labelText: 'Ad soyad')),
            const SizedBox(height: 12), TextField(controller: _department, onChanged: _markDirty, decoration: const InputDecoration(labelText: 'Bölüm / Üniversite')),
            const SizedBox(height: 12), TextField(controller: _bio, onChanged: _markDirty, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Hakkımda')),
            const SizedBox(height: 12), TextField(controller: _skills, onChanged: _markDirty, decoration: const InputDecoration(labelText: 'Yetenekler', hintText: 'Flutter, Dart, Firebase')),
            const SizedBox(height: 12), TextField(controller: _github, onChanged: _markDirty, decoration: const InputDecoration(labelText: 'GitHub URL')),
            const SizedBox(height: 20), FilledButton(onPressed: _saving ? null : () => _save(user), child: _saving ? const CircularProgressIndicator() : const Text('Profili kaydet')),
          ]))))));
        },
      ),
    );
  }
}

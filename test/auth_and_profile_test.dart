import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devhub/config/auth_config.dart';
import 'package:devhub/models/app_user.dart';
import 'package:devhub/screens/auth/auth_gate.dart';
import 'package:devhub/screens/auth/login_screen.dart';
import 'package:devhub/screens/home/home_screen.dart';
import 'package:devhub/screens/profile/profile_screen.dart';
import 'package:devhub/services/auth_service.dart';
import 'package:devhub/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser implements User {
  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final String? photoURL;

  _FakeUser({
    required this.uid,
    this.email,
    this.displayName,
  }) : photoURL = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthService implements AuthService {
  final StreamController<User?> _controller;
  User? _currentUser;

  _FakeAuthService({User? initialUser})
      : _currentUser = initialUser,
        _controller = StreamController<User?>.broadcast();

  void emitUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<void> signOut() async {
    emitUser(null);
  }

  Future<void> dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirestoreService implements FirestoreService {
  final Map<String, AppUser> _store = {};
  final StreamController<AppUser?> _profileController =
      StreamController<AppUser?>.broadcast();

  void seedUser(AppUser user) {
    _store[user.id] = user;
  }

  @override
  Stream<AppUser?> streamUserProfile(String uid) async* {
    yield _store[uid];
    yield* _profileController.stream;
  }

  @override
  Future<AppUser?> getUserProfile(String uid) async => _store[uid];

  @override
  Future<void> createUserProfileIfMissing(AppUser user) async {
    _store.putIfAbsent(user.id, () => user);
  }

  @override
  Future<void> saveUserProfile(AppUser user) async {
    _store[user.id] = user;
    _profileController.add(user);
  }

  Future<void> dispose() => _profileController.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AppUser veri sözleşmesi', () {
    test('toMap ortak alanları içerir ve email alanını Firestore\'a yazmaz',
        () {
      final createdAt = DateTime.utc(2026, 1, 10, 12, 0);
      final updatedAt = DateTime.utc(2026, 1, 11, 14, 30);

      final user = AppUser(
        id: 'uid-1',
        name: 'Enes Yılmaz',
        bio: 'Flutter geliştirici',
        department: 'Bilgisayar Mühendisliği',
        skills: const ['Flutter', 'Dart'],
        githubUrl: 'https://github.com/enes',
        photoUrl: 'https://example.com/avatar.png',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = user.toMap();

      expect(map.containsKey('email'), isFalse);
      expect(map['name'], 'Enes Yılmaz');
      expect(map['bio'], 'Flutter geliştirici');
      expect(map['department'], 'Bilgisayar Mühendisliği');
      expect(map['skills'], ['Flutter', 'Dart']);
      expect(map['githubUrl'], 'https://github.com/enes');
      expect(map['photoUrl'], 'https://example.com/avatar.png');
      expect(map['createdAt'], Timestamp.fromDate(createdAt));
      expect(map['updatedAt'], Timestamp.fromDate(updatedAt));
    });

    test('fromMap ve copyWith tüm profil alanlarını doğru işler', () {
      final createdAt = DateTime.utc(2026, 2, 1, 9, 0);
      final updatedAt = DateTime.utc(2026, 2, 2, 10, 0);

      final user = AppUser.fromMap({
        'name': 'Ali Veli',
        'bio': 'Backend developer',
        'department': 'Yazılım Mühendisliği',
        'skills': ['Go', 'Docker'],
        'githubUrl': 'https://github.com/aliveli',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      }, 'uid-2');

      expect(user.id, 'uid-2');
      expect(user.name, 'Ali Veli');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.createdAt?.toUtc(), createdAt);
      expect(user.updatedAt?.toUtc(), updatedAt);

      final updated = user.copyWith(bio: 'Fullstack developer');
      expect(updated.id, 'uid-2');
      expect(updated.name, 'Ali Veli');
      expect(updated.bio, 'Fullstack developer');
      expect(updated.createdAt?.toUtc(), createdAt);
    });
  });

  group('AuthConfig', () {
    test('ilk aşamada yalnızca e-posta/şifre girişi aktiftir', () {
      expect(AuthConfig.enableGoogle, isFalse);
      expect(AuthConfig.enableGithub, isFalse);
      expect(AuthConfig.enableMicrosoft, isFalse);
      expect(AuthConfig.enableLinkedin, isFalse);
      expect(AuthConfig.enableGuest, isFalse);
      expect(AuthConfig.hasAnySocialLogin, isFalse);
    });
  });

  group('AuthGate', () {
    testWidgets(
        'oturum durumuna göre LoginScreen ve HomeScreen arasında geçiş yapar',
        (tester) async {
      final fakeAuth = _FakeAuthService();

      await tester.pumpWidget(
        MaterialApp(home: AuthGate(authService: fakeAuth)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      fakeAuth.emitUser(null);
      await tester.pump();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Google ile Giriş Yap'), findsNothing);

      fakeAuth.emitUser(_FakeUser(uid: 'u1', email: 'enes@sakarya.edu.tr'));
      await tester.pump();
      expect(find.byType(HomeScreen), findsOneWidget);

      await fakeAuth.dispose();
    });
  });

  group('ProfileScreen', () {
    testWidgets('oturum açmış kullanıcının profil bilgilerini gösterir',
        (tester) async {
      final fakeUser = _FakeUser(
        uid: 'u1',
        email: 'enes@sakarya.edu.tr',
        displayName: 'Enes',
      );
      final fakeAuth = _FakeAuthService(initialUser: fakeUser);
      final fakeFirestore = _FakeFirestoreService()
        ..seedUser(
          const AppUser(
            id: 'u1',
            name: 'Enes Yılmaz',
            department: 'Bilgisayar Mühendisliği',
            bio: 'Mobil geliştirici',
            skills: ['Flutter', 'Firebase'],
            githubUrl: 'https://github.com/enes',
          ),
        );

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            authService: fakeAuth,
            firestoreService: fakeFirestore,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Enes Yılmaz'), findsOneWidget);
      expect(find.text('enes@sakarya.edu.tr'), findsOneWidget);
      expect(find.text('Bilgisayar Mühendisliği'), findsOneWidget);
      expect(find.text('Mobil geliştirici'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);

      await fakeAuth.dispose();
      await fakeFirestore.dispose();
    });
  });
}

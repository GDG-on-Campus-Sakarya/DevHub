import 'dart:async';

import 'package:devhub/screens/home/home_screen.dart';
import 'package:devhub/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser implements User {
  @override
  final String uid;

  _FakeUser({required this.uid});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({User? initialUser}) : _currentUser = initialUser;

  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  User? _currentUser;
  bool signOutCalled = false;

  void setUser(User? user) {
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
    signOutCalled = true;
    setUser(null);
  }

  Future<void> dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpWithSize(
  WidgetTester tester,
  Size size,
  Widget child,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pumpAndSettle();
}

void main() {
  group('HomeScreen responsive layout', () {
    testWidgets('mobil, tablet ve desktop boyutlarinda cokmeden render edilir',
        (tester) async {
      final auth = _FakeAuthService();

      for (final size in const [
        Size(390, 844), // Mobil
        Size(768, 1024), // Tablet
        Size(1440, 900), // Desktop
      ]) {
        await _pumpWithSize(tester, size, HomeScreen(authService: auth));
        expect(find.text('DevHub'), findsWidgets);
        expect(find.text('Fikirden ekibe, üç adımda.'), findsOneWidget);
      }

      await auth.dispose();
    });
  });

  group('HomeScreen oturum menusu ve cikis yap', () {
    testWidgets(
        'mobil hamburger menusu oturum durumuna gore guncellenir ve cikis yapar',
        (tester) async {
      final auth = _FakeAuthService(initialUser: _FakeUser(uid: 'u1'));

      await _pumpWithSize(
        tester,
        const Size(390, 844),
        HomeScreen(authService: auth),
      );

      await tester.tap(find.byTooltip('Menüyü aç'));
      await tester.pumpAndSettle();

      expect(find.text('Giriş yap'), findsNothing);
      expect(find.text('Kayıt ol'), findsNothing);
      expect(find.text('Profilim'), findsOneWidget);
      expect(find.text('Başvurularım'), findsOneWidget);
      expect(find.text('Çıkış yap'), findsOneWidget);

      await tester.tap(find.text('Çıkış yap'));
      await tester.pumpAndSettle();

      expect(auth.signOutCalled, isTrue);

      await tester.tap(find.byTooltip('Menüyü aç'));
      await tester.pumpAndSettle();

      expect(find.text('Giriş yap'), findsOneWidget);
      expect(find.text('Kayıt ol'), findsOneWidget);
      expect(find.text('Çıkış yap'), findsNothing);

      await auth.dispose();
    });

    testWidgets(
        'desktop ust bar oturum acikken giris/kayit gizler ve cikis yapar',
        (tester) async {
      final auth = _FakeAuthService(initialUser: _FakeUser(uid: 'u1'));

      await _pumpWithSize(
        tester,
        const Size(1440, 900),
        HomeScreen(authService: auth),
      );

      expect(find.text('Giriş yap'), findsNothing);
      expect(find.text('Ücretsiz katıl'), findsNothing);
      expect(find.text('Profilim'), findsOneWidget);
      expect(find.text('Başvurularım'), findsOneWidget);
      expect(find.text('Çıkış yap'), findsOneWidget);

      await tester.tap(find.text('Çıkış yap'));
      await tester.pumpAndSettle();

      expect(auth.signOutCalled, isTrue);
      expect(find.text('Giriş yap'), findsOneWidget);
      expect(find.text('Ücretsiz katıl'), findsOneWidget);

      await auth.dispose();
    });
  });
}

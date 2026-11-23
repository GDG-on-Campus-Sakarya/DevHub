import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devhub/screens/auth/login_screen.dart';

void main() {
  testWidgets('DevHub giriş ekranı açılır', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('DevHub’a hoş geldin'), findsOneWidget);
    expect(find.text('Giriş yap'), findsOneWidget);
  });
}

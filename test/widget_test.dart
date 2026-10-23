import 'package:flutter_test/flutter_test.dart';
import 'package:devhub/app.dart';

void main() {
  testWidgets('DevHub ana ekranı açılır', (tester) async {
    await tester.pumpWidget(const DevHubApp());
    expect(find.text('DevHub'), findsOneWidget);
  });
}

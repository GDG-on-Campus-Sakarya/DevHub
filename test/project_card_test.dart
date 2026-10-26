import 'package:devhub/models/project.dart';
import 'package:devhub/widgets/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const project = Project(
    id: 'p1',
    title: 'Study Spaces',
    description: 'Kampüsteki sessiz çalışma alanlarını bul.',
    ownerId: 'u1',
    ownerName: 'Sofia Alvarez',
    technologies: ['Flutter', 'Firebase', 'Dart'],
    neededRoles: ['Mobil Geliştirici'],
    memberIds: ['u1', 'u2', 'u3'],
  );

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SizedBox(width: 400, child: child))),
      );

  testWidgets('kart başlık, teknoloji, rol, sahip ve üye sayısını gösterir', (tester) async {
    await tester.pumpWidget(wrap(const ProjectCard(project: project)));

    expect(find.text('Study Spaces'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('1 AÇIK POZİSYON'), findsOneWidget);
    expect(find.text('Proje sahibi · Sofia Alvarez'), findsOneWidget);
    expect(find.text('3 üye'), findsOneWidget);
    expect(find.text('Projeyi İncele'), findsOneWidget);
    // onApply verilmediğinde başvur butonu gösterilmez (ana sayfa kullanımı)
    expect(find.text('Şimdi başvur'), findsNothing);
  });

  testWidgets('onApply ve onTap çağrılır', (tester) async {
    var applied = 0;
    var opened = 0;
    await tester.pumpWidget(wrap(ProjectCard(
      project: project,
      onApply: () => applied++,
      onTap: () => opened++,
    )));

    await tester.tap(find.text('Şimdi başvur'));
    await tester.tap(find.text('Projeyi İncele'));
    expect(applied, 1);
    expect(opened, 1);
  });
}

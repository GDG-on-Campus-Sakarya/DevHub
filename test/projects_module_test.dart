import 'dart:async';

import 'package:devhub/models/project.dart';
import 'package:devhub/screens/projects/project_detail_screen.dart';
import 'package:devhub/screens/projects/projects_screen.dart';
import 'package:devhub/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProjectService implements ProjectService {
  _FakeProjectService({
    this.userId = 'user-1',
    List<Project> initialProjects = const [],
  })  : canContributeFlag = true,
        _projects = List<Project>.from(initialProjects);

  final String? userId;
  final bool canContributeFlag;
  final List<Project> _projects;
  final StreamController<List<Project>> _allController =
      StreamController<List<Project>>.broadcast();
  final StreamController<Project?> _singleController =
      StreamController<Project?>.broadcast();

  String? deletedProjectId;

  @override
  String? get currentUserId => userId;

  @override
  bool get canContribute => canContributeFlag;

  @override
  Stream<List<Project>> streamAllProjects() async* {
    yield List<Project>.from(_projects);
    yield* _allController.stream;
  }

  @override
  Stream<Project?> streamProject(String projectId) async* {
    yield _projects.where((p) => p.id == projectId).firstOrNull;
    yield* _singleController.stream;
  }

  @override
  Future<void> deleteProject(Project project) async {
    deletedProjectId = project.id;
    _projects.removeWhere((p) => p.id == project.id);
    _allController.add(List<Project>.from(_projects));
    _singleController.add(null);
  }

  Future<void> dispose() async {
    await _allController.close();
    await _singleController.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Project modeli', () {
    test('kategori, kontenjan ve effectiveStatus alanlarını doğru hesaplar',
        () {
      const openProject = Project(
        id: 'p1',
        title: 'DevHub Mobile',
        description: 'Flutter topluluk uygulaması geliştirme projesi.',
        ownerId: 'u1',
        category: 'Mobil',
        capacity: 3,
        technologies: ['Flutter', 'Firebase'],
        memberIds: ['u1', 'u2'],
      );

      expect(openProject.isFull, isFalse);
      expect(openProject.canApply, isTrue);
      expect(openProject.remainingSlots, 1);
      expect(openProject.effectiveStatus, Project.statusOpen);

      final fullProject = openProject.copyWith(memberIds: ['u1', 'u2', 'u3']);
      expect(fullProject.isFull, isTrue);
      expect(fullProject.canApply, isFalse);
      expect(fullProject.remainingSlots, 0);
      expect(fullProject.effectiveStatus, Project.statusFull);

      final completedProject =
          openProject.copyWith(status: Project.statusCompleted);
      expect(completedProject.effectiveStatus, Project.statusCompleted);
      expect(completedProject.canApply, isFalse);

      final map = openProject.toMap();
      expect(map['category'], 'Mobil');
      expect(map['capacity'], 3);

      final restored = Project.fromMap(map, 'p1');
      expect(restored.category, 'Mobil');
      expect(restored.capacity, 3);
    });
  });

  group('ProjectsScreen arama ve filtreleme', () {
    testWidgets('arama ve filtreler birlikte çalışır, empty state temizlenir',
        (tester) async {
      final service = _FakeProjectService(
        initialProjects: const [
          Project(
            id: '1',
            title: 'Campus App',
            description: 'Üniversite kampüs rehberi ve etkinlik takibi.',
            ownerId: 'u1',
            category: 'Mobil',
            technologies: ['Flutter', 'Dart'],
            status: Project.statusOpen,
            memberIds: ['u1'],
            capacity: 4,
          ),
          Project(
            id: '2',
            title: 'AI Summarizer',
            description: 'Ders notlarını özetleyen yapay zeka aracı.',
            ownerId: 'u2',
            category: 'Yapay Zeka',
            technologies: ['Python', 'FastAPI'],
            status: Project.statusCompleted,
            memberIds: ['u2', 'u3'],
            capacity: 2,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: ProjectsScreen(service: service)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Campus App'), findsOneWidget);
      expect(find.text('AI Summarizer'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Python');
      await tester.pumpAndSettle();

      expect(find.text('Campus App'), findsNothing);
      expect(find.text('AI Summarizer'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'OlmayanProje');
      await tester.pumpAndSettle();

      expect(
        find.text('Seçilen kriterlere uygun proje bulunamadı.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Filtreleri temizle').first);
      await tester.pumpAndSettle();

      expect(find.text('Campus App'), findsOneWidget);
      expect(find.text('AI Summarizer'), findsOneWidget);

      await service.dispose();
    });
  });

  group('ProjectDetailScreen silme ve kontenjan', () {
    testWidgets('proje sahibi onay sonrası projesini silebilir',
        (tester) async {
      final service = _FakeProjectService(
        userId: 'owner-1',
        initialProjects: const [
          Project(
            id: 'p1',
            title: 'Silinecek Proje',
            description: 'Test amaçlı oluşturulmuş proje açıklaması.',
            ownerId: 'owner-1',
            category: 'Web',
            memberIds: ['owner-1'],
            capacity: 3,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectDetailScreen(projectId: 'p1', service: service),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Projeyi sil'), 200);
      expect(find.text('Projeyi düzenle'), findsOneWidget);
      expect(find.text('Projeyi sil'), findsOneWidget);

      await tester.tap(find.text('Projeyi sil'));
      await tester.pumpAndSettle();

      expect(find.text('Sil'), findsOneWidget);
      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();

      expect(service.deletedProjectId, 'p1');
      await service.dispose();
    });

    testWidgets('kontenjan doluysa üye olmayan kullanıcı başvuramaz',
        (tester) async {
      final service = _FakeProjectService(
        userId: 'other-user',
        initialProjects: const [
          Project(
            id: 'p2',
            title: 'Dolu Proje',
            description: 'Kontenjanı dolmuş örnek proje açıklaması.',
            ownerId: 'owner-1',
            category: 'Mobil',
            memberIds: ['owner-1', 'member-2'],
            capacity: 2,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectDetailScreen(projectId: 'p2', service: service),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Projeyi düzenle'), findsNothing);
      expect(find.text('Projeyi sil'), findsNothing);
      expect(find.text('Projeye başvur'), findsNothing);
      expect(
        find.text('Bu projenin kontenjanı dolmuştur.'),
        findsOneWidget,
      );

      await service.dispose();
    });
  });
}

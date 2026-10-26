import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devhub/models/project.dart';
import 'package:devhub/models/project_application.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Project', () {
    test('fromMap eksik alanlarda güvenli varsayılanlar kullanır', () {
      final p = Project.fromMap({'title': 'X', 'ownerId': 'u1'}, 'p1');
      expect(p.id, 'p1');
      expect(p.status, Project.statusOpen);
      expect(p.technologies, isEmpty);
      expect(p.memberIds, isEmpty);
      expect(p.createdAt, isNull);
    });

    test('toMap / fromMap gidiş-dönüş', () {
      final created = DateTime(2026, 10, 1);
      final map = const Project(
        id: 'p1',
        title: 'Campus Connect',
        description: 'Kampüs etkinlikleri',
        ownerId: 'u1',
        ownerName: 'Jordan',
        technologies: ['Flutter', 'Firebase'],
        neededRoles: ['Mobil Geliştirici'],
        status: Project.statusClosed,
        memberIds: ['u1'],
      ).toMap()
        ..['createdAt'] = Timestamp.fromDate(created);

      final p = Project.fromMap(map, 'p1');
      expect(p.title, 'Campus Connect');
      expect(p.technologies, ['Flutter', 'Firebase']);
      expect(p.neededRoles, ['Mobil Geliştirici']);
      expect(p.isOpen, isFalse);
      expect(p.createdAt, created);
      expect(map.containsKey('id'), isFalse);
    });

    test('sahiplik ve üyelik kontrolleri', () {
      const p = Project(id: 'p', title: 't', description: 'd', ownerId: 'u1', memberIds: ['u1', 'u2']);
      expect(p.isOwner('u1'), isTrue);
      expect(p.isOwner('u2'), isFalse);
      expect(p.isOwner(null), isFalse);
      expect(p.isMember('u2'), isTrue);
      expect(p.isMember('u3'), isFalse);
    });

    test('copyWith ownerId değerini değiştirmez', () {
      const p = Project(id: 'p', title: 't', description: 'd', ownerId: 'u1');
      final edited = p.copyWith(title: 'yeni', status: Project.statusClosed);
      expect(edited.ownerId, 'u1');
      expect(edited.title, 'yeni');
      expect(edited.status, Project.statusClosed);
    });
  });

  group('ProjectApplication', () {
    test('yeni başvuru varsayılan olarak pending', () {
      const a = ProjectApplication(id: 'a', projectId: 'p', applicantId: 'u');
      expect(a.status, ProjectApplication.statusPending);
      expect(a.isPending, isTrue);
      expect(a.toMap()['status'], 'pending');
    });

    test('belge ID sabit ve proje+kullanıcıya bağlı', () {
      expect(ProjectApplication.docId('p1', 'u2'), 'p1_u2');
    });

    test('fromMap alanları okur', () {
      final a = ProjectApplication.fromMap({
        'projectId': 'p1',
        'applicantId': 'u2',
        'ownerId': 'u1',
        'message': 'Merhaba',
        'status': 'accepted',
      }, 'p1_u2');
      expect(a.ownerId, 'u1');
      expect(a.status, ProjectApplication.statusAccepted);
      expect(a.isPending, isFalse);
    });
  });
}

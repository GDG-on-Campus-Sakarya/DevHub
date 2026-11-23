import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devhub/models/app_user.dart';
import 'package:devhub/models/project.dart';
import 'package:devhub/models/project_application.dart';

const projectId = 'AbCdEfGhIjKlMnOpQrSt';
const user = AppUser(id: 'alice', name: 'Ada', email: 'alice@example.invalid',
  bio: 'Veri geliştirici', department: 'Bilişim', skills: ['Dart', 'C#'],
  githubUrl: 'https://github.com/example');
const project = Project(id: projectId, title: 'DevHub',
  description: 'Öğrenci proje geliştirme platformu', ownerId: 'alice',
  ownerName: 'Ada', technologies: ['Flutter', 'Firebase'],
  neededRoles: ['Backend Geliştirici'], memberIds: ['alice']);
const application = ProjectApplication(id: '${projectId}_bob',
  projectId: projectId, applicantId: 'bob', ownerId: 'alice',
  projectTitle: 'DevHub', applicantName: 'Bora', message: 'Katılmak istiyorum.');

void main() {
  test('Service trim removes Unicode whitespace including NEL and BOM', () {
    for (final value in [' ', '\u00a0', '\u0085', '\ufeff']) {
      expect(value.trim(), '');
    }
  });
  test('AppUser minimal codec adds only name and skills', () {
    expect(const AppUser(id: 'u', name: 'Ad').toMap(), {'name': 'Ad', 'skills': []});
  });
  test('AppUser full codec roundtrip preserves every field', () {
    expect(AppUser.fromMap(user.toMap(), user.id).toMap(), user.toMap());
    expect(user.toMap().containsKey('id'), false);
  });
  test('AppUser optional empty values remain valid strings', () {
    expect(const AppUser(id: 'u', name: '', bio: '', department: '', githubUrl: '').toMap(),
      {'name': '', 'bio': '', 'department': '', 'skills': [], 'githubUrl': ''});
  });
  test('Project codec has service timestamps outside toMap', () {
    expect(Project.fromMap(project.toMap(), project.id).toMap(), project.toMap());
    expect(project.toMap().containsKey('createdAt'), false);
    expect(project.toMap().containsKey('id'), false);
  });
  test('Project timestamp read uses real Firestore Timestamp', () {
    final date = DateTime.utc(2026, 11, 4);
    final restored = Project.fromMap({...project.toMap(), 'createdAt': Timestamp.fromDate(date),
      'updatedAt': Timestamp.fromDate(date)}, project.id);
    expect(restored.createdAt?.toUtc(), date);
    expect(restored.updatedAt?.toUtc(), date);
  });
  test('Project defaults and copyWith preserve identity', () {
    final p = project.copyWith(title: 'Yeni Proje', status: Project.statusClosed);
    expect(p.ownerId, project.ownerId);
    expect(p.ownerName, project.ownerName);
    expect(p.memberIds, ['alice']);
    expect(p.isOpen, false);
    expect(const Project(id: 'p', title: 'Ad', description: 'A', ownerId: 'u').technologies, isEmpty);
  });
  test('Application codec roundtrip preserves denormalized fields', () {
    expect(ProjectApplication.fromMap(application.toMap(), application.id).toMap(), application.toMap());
    expect(application.toMap().containsKey('createdAt'), false);
    expect(application.toMap().containsKey('id'), false);
  });
  test('Application deterministic ID preserves underscore in Auth UID', () {
    expect(ProjectApplication.docId(projectId, 'bob_with_under'), '${projectId}_bob_with_under');
    expect(application.isPending, true);
  });
  test('Application timestamp read and default status', () {
    final date = DateTime.utc(2026, 11, 4);
    final a = ProjectApplication.fromMap({...application.toMap(), 'createdAt': Timestamp.fromDate(date)}, application.id);
    expect(a.createdAt?.toUtc(), date);
    expect(ProjectApplication.fromMap({}, 'missing').status, 'pending');
  });
  test('Export actual model maps for Rules compatibility tests', () {
    final rows = [
      {'collection': 'users', 'id': user.id, 'data': user.toMap()},
      {'collection': 'users', 'id': 'minimal', 'data': const AppUser(id: 'minimal', name: 'Ad').toMap()},
      {'collection': 'projects', 'id': project.id, 'data': project.toMap()},
      {'collection': 'applications', 'id': application.id, 'data': application.toMap()},
    ];
    File('codec-ciktilari.json').writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(rows)}\n');
    expect(rows.length, 4);
  });
}

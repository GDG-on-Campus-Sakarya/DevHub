@TestOn('browser')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
// The generated browser-test pubspec declares these direct dependencies.
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_web/firebase_core_web.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_web/firebase_auth_web.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:devhub/models/app_user.dart';
import 'package:devhub/models/project.dart';
import 'package:devhub/models/project_application.dart';
import 'package:devhub/services/firestore_service.dart';
import 'package:devhub/services/project_service.dart';

// Real production services, real browser plugins; all writes are local demo data.
const demoProject = 'demo-devhub-mvp';
final apps = <FirebaseApp>[];
final stores = <FirebaseFirestore>[];
final auths = <FirebaseAuth>[];
late ProjectService owner;
late ProjectService applicant;
late FirestoreService ownerProfile;
late FirestoreService applicantProfile;
Future<void> client(String name) async {
  expect(Uri.base.host, anyOf('localhost', '127.0.0.1'));
  final app = await Firebase.initializeApp(name: name, options: const FirebaseOptions(
    apiKey: 'demo-devhub-local-only', appId: '1:123456:web:local',
    messagingSenderId: '123456', projectId: demoProject,
    authDomain: 'demo-devhub-mvp.firebaseapp.com'));
  expect(app.options.projectId, demoProject);
  final auth = FirebaseAuth.instanceFor(app: app);
  await auth.useAuthEmulator('127.0.0.1', 9098, automaticHostMapping: false);
  final store = FirebaseFirestore.instanceFor(app: app);
  store.settings = const Settings(persistenceEnabled: false);
  store.useFirestoreEmulator('127.0.0.1', 8088, automaticHostMapping: false);
  apps.add(app); stores.add(store); auths.add(auth);
}
Future<Project> create() async {
  final id = await owner.createProject(title: 'Servis Projesi',
    description: 'Yalnız yerel Emulator üzerinde sentetik servis testi.',
    technologies: ['Flutter', 'Firebase'], neededRoles: ['Backend Geliştirici']);
  return (await owner.streamProject(id).first)!;
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  setUpAll(() async {
    await client('data-owner'); await client('data-applicant');
    for (var i = 0; i < auths.length; i++) {
      await auths[i].createUserWithEmailAndPassword(
        email: 'service-$i-${DateTime.now().microsecondsSinceEpoch}@example.invalid',
        password: 'LocalTestOnly-123456');
      await auths[i].currentUser!.updateDisplayName(i == 0 ? 'Sahip' : 'Basvuran');
    }
    owner = ProjectService(firestore: stores[0], auth: auths[0]);
    applicant = ProjectService(firestore: stores[1], auth: auths[1]);
    ownerProfile = FirestoreService(firestore: stores[0]);
    applicantProfile = FirestoreService(firestore: stores[1]);
  });
  tearDownAll(() async {
    for (final store in stores) { await store.terminate(); }
    for (final app in apps) { await app.delete(); }
  });
  test('I01 real profile save/get/stream and merge', () async {
    final uid = auths[0].currentUser!.uid;
    final user = AppUser(id: uid, name: 'Sahip', email: auths[0].currentUser!.email,
      bio: 'Sentetik biyografi', skills: const ['Dart']);
    await ownerProfile.saveUserProfile(user);
    expect((await ownerProfile.getUserProfile(uid))!.name, 'Sahip');
    await ownerProfile.saveUserProfile(user.copyWith(name: 'Yeni Ad'));
    expect((await ownerProfile.streamUserProfile(uid).first)!.bio, 'Sentetik biyografi');
  });
  test('I02 create/read/list/update uses real model and server timestamps', () async {
    final p = await create();
    expect(p.id, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
    expect(p.ownerId, auths[0].currentUser!.uid);
    expect(p.memberIds, [p.ownerId]); expect(p.createdAt, isNotNull);
    expect((await owner.streamMyProjects().first).any((x) => x.id == p.id), true);
    expect((await applicant.streamOpenProjects().first).any((x) => x.id == p.id), true);
    await owner.updateProject(p.copyWith(title: 'Yeni Baslik'));
    expect((await owner.streamProject(p.id).first)!.title, 'Yeni Baslik');
  });
  test('I03 apply and both application streams use actual transaction/query code', () async {
    final p = await create(); await applicant.applyToProject(p, '  Katilmak istiyorum.  ');
    final a = (await applicant.streamMyApplicationFor(p.id).first)!;
    expect(a.message, 'Katilmak istiyorum.'); expect(a.status, 'pending');
    expect(a.applicantId, auths[1].currentUser!.uid);
    expect((await applicant.streamMyApplications().first).any((x) => x.id == a.id), true);
    expect((await owner.streamIncomingApplications(projectId: p.id)
      .firstWhere((items) => items.length == 1).timeout(const Duration(seconds: 20))).single.id, a.id);
  });
  test('I04 duplicate application is rejected by existing transaction', () async {
    final p = await create(); await applicant.applyToProject(p, 'Ilk basvuru');
    await expectLater(applicant.applyToProject(p, 'Ikinci basvuru'), throwsA(anything));
    expect((await owner.streamIncomingApplications(projectId: p.id)
      .firstWhere((items) => items.length == 1).timeout(const Duration(seconds: 20))).length, 1);
  });
  test('I05 actual decision batch accepts and adds exactly one member', () async {
    final p = await create(); await applicant.applyToProject(p, 'Kabul testi');
    final a = (await applicant.streamMyApplicationFor(p.id).first)!;
    await owner.decideApplication(a, accept: true);
    expect((await applicant.streamMyApplicationFor(p.id)
      .firstWhere((a) => a?.status == 'accepted').timeout(const Duration(seconds: 20)))!.status, 'accepted');
    expect((await owner.streamProject(p.id).first)!.memberIds,
      [auths[0].currentUser!.uid, auths[1].currentUser!.uid]);
    await expectLater(owner.decideApplication(a, accept: false), throwsA(anything));
  });
  test('I06 real rejection does not create membership', () async {
    final p = await create();
    await applicant.applyToProject(p, 'Red testi');
    final a = (await applicant.streamMyApplicationFor(p.id).first)!;
    try {
      await owner.decideApplication(a, accept: false);
    } catch (error, stack) {
      fail('I06 decision write failed: $error\\n$stack');
    }
    ProjectApplication? rejected;
    try {
      rejected = await applicant.streamMyApplicationFor(p.id)
        .firstWhere((a) => a?.status == 'rejected')
        .timeout(const Duration(seconds: 20));
    } catch (error, stack) {
      fail('I06 rejected-status stream failed: $error\\n$stack');
    }
    expect(rejected?.status, 'rejected', reason: 'I06 status was not observed as rejected');
    Project? finalProject;
    try {
      finalProject = await owner.streamProject(p.id).first;
    } catch (error, stack) {
      fail('I06 project stream failed: $error\\n$stack');
    }
    expect(finalProject?.memberIds, [auths[0].currentUser!.uid],
      reason: 'I06 rejection must not add the applicant to membership');
  });
  test('I07 another authenticated client cannot read private profile', () async {
    await expectLater(applicantProfile.getUserProfile(auths[0].currentUser!.uid),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')));
  });
  test('I08 non-owner update and own-project application are rejected', () async {
    final p = await create();
    await expectLater(applicant.updateProject(p.copyWith(title: 'Sahte Baslik')), throwsA(anything));
    await expectLater(owner.applyToProject(p, 'Kendi projem'), throwsA(anything));
  });
  test('I09 stale open project cannot bypass live closed-project Rules', () async {
    final p = await create(); await owner.updateProject(p.copyWith(status: Project.statusClosed));
    await expectLater(applicant.applyToProject(p, 'Eski nesne ile basvuru'), throwsA(anything));
    expect(await applicant.streamMyApplicationFor(p.id).first, isNull);
  });
  test('I10 guest can read but cannot contribute in Emulator', () async {
    await client('data-guest'); await auths[2].signInAnonymously();
    final guest = ProjectService(firestore: stores[2], auth: auths[2]);
    expect(guest.canContribute, false); expect(await guest.streamOpenProjects().first, isNotEmpty);
    await expectLater(guest.createProject(title: 'Misafir Projesi',
      description: 'Yazma reddedilmelidir.', technologies: [], neededRoles: []), throwsA(anything));
  });
}

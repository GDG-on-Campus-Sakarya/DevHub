import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectApplication {
  const ProjectApplication({
    required this.id,
    required this.projectId,
    required this.applicantId,
    this.ownerId = '',
    this.projectTitle = '',
    this.applicantName = '',
    this.message = '',
    this.status = statusPending,
    this.createdAt,
    this.updatedAt,
  });

  // Firestore'da saklanan durum değerleri
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';

  final String id;
  final String projectId;
  final String applicantId;
  final String ownerId; // Projenin sahibi; sorgu ve güvenlik kuralları için tutulur
  final String projectTitle;
  final String applicantName;
  final String message;
  final String status; // pending, accepted, rejected
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => status == statusPending;

  // Bir kullanıcı bir projeye yalnızca bir kez başvurabilsin diye belge ID'si sabitlendi
  static String docId(String projectId, String applicantId) =>
      '${projectId}_$applicantId';

  // Firestore'dan gelen JSON haritası ProjectApplication nesnesine dönüştürüldü
  factory ProjectApplication.fromMap(Map<String, dynamic> data, String id) {
    return ProjectApplication(
      id: id,
      projectId: data['projectId'] as String? ?? '',
      applicantId: data['applicantId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      projectTitle: data['projectTitle'] as String? ?? '',
      applicantName: data['applicantName'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? statusPending,
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  // Zaman damgaları servis katmanında serverTimestamp ile eklenir
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'applicantId': applicantId,
      'ownerId': ownerId,
      'projectTitle': projectTitle,
      'applicantName': applicantName,
      'message': message,
      'status': status,
    };
  }
}

DateTime? _toDate(Object? value) => value is Timestamp ? value.toDate() : null;

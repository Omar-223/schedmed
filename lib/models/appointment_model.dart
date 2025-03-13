import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled
}

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String? reasonForVisit;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? notes;
  
  // Additional fields for UI display
  String? patientName;
  String? doctorName;
  String? doctorSpecialty;
  
  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    this.reasonForVisit,
    required this.status,
    required this.createdAt,
    this.notes,
    this.patientName,
    this.doctorName,
    this.doctorSpecialty,
  });
  
  // Create from Firestore document
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      reasonForVisit: data['reasonForVisit'],
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'],
      patientName: data['patientName'],
      doctorName: data['doctorName'],
      doctorSpecialty: data['doctorSpecialty'],
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'reasonForVisit': reasonForVisit,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'patientName': patientName,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
    };
  }
  
  // Create a copy with updated fields
  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? appointmentDate,
    String? reasonForVisit,
    AppointmentStatus? status,
    DateTime? createdAt,
    String? notes,
    String? patientName,
    String? doctorName,
    String? doctorSpecialty,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
    );
  }
  
  // Parse status from string
  static AppointmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'scheduled':
      default:
        return AppointmentStatus.scheduled;
    }
  }
} 
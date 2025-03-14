import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedmed/models/appointment_model.dart';
import 'package:schedmed/utils/firestore_schema.dart';
import 'package:uuid/uuid.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _appointmentsCollection = 
      FirestoreSchema.appointmentsCollection;

  // Create a new appointment
  Future<String> createAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime appointmentDate,
    required String timeSlot,
    required String reasonForVisit,
    String? notes,
  }) async {
    try {
      return await FirestoreSchema.createAppointmentWithSchema(
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        reasonForVisit: reasonForVisit,
        notes: notes,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get all appointments for a patient
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _appointmentsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get all appointments for a doctor
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _appointmentsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get all appointments for a specific date
  Stream<List<AppointmentModel>> getAppointmentsByDate(DateTime date) {
    // Create DateTime objects for the start and end of the day
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _appointmentsCollection
        .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointmentDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('appointmentDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get all upcoming appointments
  Stream<List<AppointmentModel>> getUpcomingAppointments() {
    DateTime now = DateTime.now();
    
    return _appointmentsCollection
        .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('status', isEqualTo: 'scheduled')
        .orderBy('appointmentDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();
        });
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      String statusString;
      switch (status) {
        case AppointmentStatus.completed:
          statusString = 'completed';
          break;
        case AppointmentStatus.cancelled:
          statusString = 'cancelled';
          break;
        default:
          statusString = 'scheduled';
      }
      
      await _appointmentsCollection.doc(appointmentId).update({
        'status': statusString,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update appointment details
  Future<void> updateAppointment(String appointmentId, {
    DateTime? appointmentDate,
    String? timeSlot,
    String? notes,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (appointmentDate != null) {
        updateData['appointmentDate'] = Timestamp.fromDate(appointmentDate);
      }
      
      if (timeSlot != null) {
        updateData['timeSlot'] = timeSlot;
      }
      
      if (notes != null) {
        updateData['notes'] = notes;
      }
      
      if (updateData.isNotEmpty) {
        await _appointmentsCollection.doc(appointmentId).update(updateData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Add sample appointments to Firestore
  Future<void> addSampleAppointments(List<Map<String, dynamic>> sampleData) async {
    try {
      await FirestoreSchema.addSampleAppointments(sampleData);
    } catch (e) {
      rethrow;
    }
  }
} 
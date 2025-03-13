import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedmed/models/doctor_model.dart';
import 'package:uuid/uuid.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _doctorsCollection = 
      FirebaseFirestore.instance.collection('doctors');

  // Add a new doctor
  Future<String> addDoctor({
    required String name,
    required String specialization,
    String? bio,
    String? profileImageUrl,
    required List<String> availableDays,
    required Map<String, List<String>> availableTimeSlots,
  }) async {
    try {
      String doctorId = const Uuid().v4();
      
      await _doctorsCollection.doc(doctorId).set({
        'name': name,
        'specialization': specialization,
        'bio': bio,
        'profileImageUrl': profileImageUrl,
        'availableDays': availableDays,
        'availableTimeSlots': availableTimeSlots,
        'createdAt': Timestamp.now(),
      });
      
      return doctorId;
    } catch (e) {
      rethrow;
    }
  }

  // Get all doctors
  Stream<List<DoctorModel>> getAllDoctors() {
    return _doctorsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DoctorModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get doctor by ID
  Future<DoctorModel> getDoctorById(String doctorId) async {
    try {
      DocumentSnapshot doc = await _doctorsCollection.doc(doctorId).get();
      if (doc.exists) {
        return DoctorModel.fromFirestore(doc);
      }
      throw Exception('Doctor not found');
    } catch (e) {
      rethrow;
    }
  }

  // Get doctors by specialization
  Stream<List<DoctorModel>> getDoctorsBySpecialization(String specialization) {
    return _doctorsCollection
        .where('specialization', isEqualTo: specialization)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DoctorModel.fromFirestore(doc))
              .toList();
        });
  }

  // Update doctor details
  Future<void> updateDoctor(String doctorId, {
    String? name,
    String? specialization,
    String? bio,
    String? profileImageUrl,
    List<String>? availableDays,
    Map<String, List<String>>? availableTimeSlots,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (name != null) {
        updateData['name'] = name;
      }
      
      if (specialization != null) {
        updateData['specialization'] = specialization;
      }
      
      if (bio != null) {
        updateData['bio'] = bio;
      }
      
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }
      
      if (availableDays != null) {
        updateData['availableDays'] = availableDays;
      }
      
      if (availableTimeSlots != null) {
        updateData['availableTimeSlots'] = availableTimeSlots;
      }
      
      if (updateData.isNotEmpty) {
        await _doctorsCollection.doc(doctorId).update(updateData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete doctor
  Future<void> deleteDoctor(String doctorId) async {
    try {
      await _doctorsCollection.doc(doctorId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get available time slots for a specific doctor on a specific date
  Future<List<String>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    try {
      // Get the doctor's schedule
      DoctorModel doctor = await getDoctorById(doctorId);
      
      // Get the day of the week (e.g., 'Monday', 'Tuesday', etc.)
      String dayOfWeek = _getDayOfWeek(date);
      
      // Check if the doctor works on this day
      if (!doctor.availableDays.contains(dayOfWeek)) {
        return [];
      }
      
      // Get all time slots for this day
      List<String> allTimeSlots = doctor.availableTimeSlots[dayOfWeek] ?? [];
      
      // Get all appointments for this doctor on this date
      QuerySnapshot appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(date.year, date.month, date.day, 0, 0, 0)))
          .where('appointmentDate', isLessThanOrEqualTo: Timestamp.fromDate(
              DateTime(date.year, date.month, date.day, 23, 59, 59)))
          .get();
      
      // Extract booked time slots
      List<String> bookedTimeSlots = appointmentsSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['timeSlot'] as String)
          .toList();
      
      // Filter out booked time slots
      List<String> availableTimeSlots = allTimeSlots
          .where((timeSlot) => !bookedTimeSlots.contains(timeSlot))
          .toList();
      
      return availableTimeSlots;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to get day of week
  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
} 
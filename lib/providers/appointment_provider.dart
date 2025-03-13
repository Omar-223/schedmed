import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schedmed/models/appointment_model.dart';
import 'package:schedmed/models/doctor_model.dart';
import 'package:schedmed/models/user_model.dart';

class AppointmentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AppointmentModel> _patientAppointments = [];
  List<AppointmentModel> _doctorAppointments = [];
  List<AppointmentModel> _allAppointments = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<AppointmentModel> get patientAppointments => _patientAppointments;
  List<AppointmentModel> get doctorAppointments => _doctorAppointments;
  List<AppointmentModel> get allAppointments => _allAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load patient appointments
  Future<void> loadPatientAppointments(String patientId) async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDate', descending: true)
          .get();
      
      _patientAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      
      // Load doctor details for each appointment
      await _loadDoctorDetails(_patientAppointments);
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: $e');
    }
  }
  
  // Load doctor appointments
  Future<void> loadDoctorAppointments(String doctorId) async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('appointmentDate', descending: true)
          .get();
      
      _doctorAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      
      // Load patient details for each appointment
      await _loadPatientDetails(_doctorAppointments);
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: $e');
    }
  }
  
  // Load all appointments (for admin)
  Future<void> loadAllAppointments() async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection('appointments')
          .orderBy('appointmentDate', descending: true)
          .get();
      
      _allAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      
      // Load patient and doctor details for each appointment
      await _loadPatientDetails(_allAppointments);
      await _loadDoctorDetails(_allAppointments);
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: $e');
    }
  }
  
  // Book a new appointment
  Future<void> bookAppointment(AppointmentModel appointment) async {
    try {
      _setLoading(true);
      
      // Get doctor details
      final doctorDoc = await _firestore
          .collection('users')
          .doc(appointment.doctorId)
          .get();
      
      if (!doctorDoc.exists) {
        throw Exception('Doctor not found');
      }
      
      final doctor = UserModel.fromFirestore(doctorDoc);
      
      // Get patient details
      final patientDoc = await _firestore
          .collection('users')
          .doc(appointment.patientId)
          .get();
      
      if (!patientDoc.exists) {
        throw Exception('Patient not found');
      }
      
      final patient = UserModel.fromFirestore(patientDoc);
      
      // Add doctor and patient names to appointment
      final appointmentWithNames = appointment.copyWith(
        doctorName: doctor.displayName,
        patientName: patient.displayName,
      );
      
      // Save appointment to Firestore
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointmentWithNames.toFirestore());
      
      // Add to local list
      _patientAppointments.add(appointmentWithNames);
      
      // Sort appointments by date
      _patientAppointments.sort((a, b) => 
          b.appointmentDate.compareTo(a.appointmentDate));
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to book appointment: $e');
    }
  }
  
  // Update appointment status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      _setLoading(true);
      
      // Update in Firestore
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': status.toString().split('.').last,
      });
      
      // Update in local lists
      _updateAppointmentInLists(appointmentId, status);
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update appointment: $e');
    }
  }
  
  // Add notes to appointment
  Future<void> addAppointmentNotes(String appointmentId, String notes) async {
    try {
      _setLoading(true);
      
      // Update in Firestore
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'notes': notes,
      });
      
      // Update in local lists
      _updateAppointmentNotesInLists(appointmentId, notes);
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update appointment notes: $e');
    }
  }
  
  // Helper methods
  Future<void> _loadDoctorDetails(List<AppointmentModel> appointments) async {
    final doctorIds = appointments
        .map((appointment) => appointment.doctorId)
        .toSet()
        .toList();
    
    for (final doctorId in doctorIds) {
      try {
        final doctorDoc = await _firestore
            .collection('users')
            .doc(doctorId)
            .get();
        
        if (doctorDoc.exists) {
          final doctor = UserModel.fromFirestore(doctorDoc);
          
          // Get doctor specialization
          String? specialization;
          final doctorProfileDoc = await _firestore
              .collection('doctors')
              .doc(doctorId)
              .get();
          
          if (doctorProfileDoc.exists) {
            final doctorProfile = DoctorModel.fromFirestore(doctorProfileDoc);
            specialization = doctorProfile.specialization;
          }
          
          // Update appointments with doctor details
          for (int i = 0; i < appointments.length; i++) {
            if (appointments[i].doctorId == doctorId) {
              appointments[i] = appointments[i].copyWith(
                doctorName: doctor.displayName,
                doctorSpecialty: specialization,
              );
            }
          }
        }
      } catch (e) {
        print('Error loading doctor details: $e');
      }
    }
  }
  
  Future<void> _loadPatientDetails(List<AppointmentModel> appointments) async {
    final patientIds = appointments
        .map((appointment) => appointment.patientId)
        .toSet()
        .toList();
    
    for (final patientId in patientIds) {
      try {
        final patientDoc = await _firestore
            .collection('users')
            .doc(patientId)
            .get();
        
        if (patientDoc.exists) {
          final patient = UserModel.fromFirestore(patientDoc);
          
          // Update appointments with patient details
          for (int i = 0; i < appointments.length; i++) {
            if (appointments[i].patientId == patientId) {
              appointments[i] = appointments[i].copyWith(
                patientName: patient.displayName,
              );
            }
          }
        }
      } catch (e) {
        print('Error loading patient details: $e');
      }
    }
  }
  
  void _updateAppointmentInLists(String appointmentId, AppointmentStatus status) {
    // Update in patient appointments
    for (int i = 0; i < _patientAppointments.length; i++) {
      if (_patientAppointments[i].id == appointmentId) {
        _patientAppointments[i] = _patientAppointments[i].copyWith(
          status: status,
        );
        break;
      }
    }
    
    // Update in doctor appointments
    for (int i = 0; i < _doctorAppointments.length; i++) {
      if (_doctorAppointments[i].id == appointmentId) {
        _doctorAppointments[i] = _doctorAppointments[i].copyWith(
          status: status,
        );
        break;
      }
    }
    
    // Update in all appointments
    for (int i = 0; i < _allAppointments.length; i++) {
      if (_allAppointments[i].id == appointmentId) {
        _allAppointments[i] = _allAppointments[i].copyWith(
          status: status,
        );
        break;
      }
    }
    
    notifyListeners();
  }
  
  void _updateAppointmentNotesInLists(String appointmentId, String notes) {
    // Update in patient appointments
    for (int i = 0; i < _patientAppointments.length; i++) {
      if (_patientAppointments[i].id == appointmentId) {
        _patientAppointments[i] = _patientAppointments[i].copyWith(
          notes: notes,
        );
        break;
      }
    }
    
    // Update in doctor appointments
    for (int i = 0; i < _doctorAppointments.length; i++) {
      if (_doctorAppointments[i].id == appointmentId) {
        _doctorAppointments[i] = _doctorAppointments[i].copyWith(
          notes: notes,
        );
        break;
      }
    }
    
    // Update in all appointments
    for (int i = 0; i < _allAppointments.length; i++) {
      if (_allAppointments[i].id == appointmentId) {
        _allAppointments[i] = _allAppointments[i].copyWith(
          notes: notes,
        );
        break;
      }
    }
    
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
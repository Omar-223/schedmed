import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schedmed/models/doctor_model.dart';
import 'package:schedmed/models/user_model.dart';

class DoctorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<DoctorModel> _doctors = [];
  DoctorModel? _selectedDoctor;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<DoctorModel> get doctors => _doctors;
  DoctorModel? get selectedDoctor => _selectedDoctor;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all doctors
  Future<void> loadDoctors() async {
    try {
      _setLoading(true);
      
      // First, get all users with doctor role
      final userSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      
      final List<UserModel> doctorUsers = userSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      
      // Then, get doctor details from doctors collection
      _doctors = [];
      
      for (final user in doctorUsers) {
        try {
          final doctorDoc = await _firestore
              .collection('doctors')
              .doc(user.uid)
              .get();
          
          if (doctorDoc.exists) {
            final doctor = DoctorModel.fromFirestore(doctorDoc);
            
            // Combine user data with doctor data
            final combinedDoctor = doctor.copyWith(
              name: user.displayName ?? 'Dr.',
              profileImageUrl: user.profileImageUrl,
            );
            
            _doctors.add(combinedDoctor);
          } else {
            // Create a basic doctor model from user data
            final basicDoctor = DoctorModel(
              id: user.uid,
              name: user.displayName ?? 'Dr.',
              specialization: 'General Physician',
              profileImageUrl: user.profileImageUrl,
            );
            
            _doctors.add(basicDoctor);
          }
        } catch (e) {
          print('Error loading doctor details: $e');
        }
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load doctors: $e');
    }
  }
  
  // Get doctor by ID
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      _setLoading(true);
      
      // First, get user data
      final userDoc = await _firestore
          .collection('users')
          .doc(doctorId)
          .get();
      
      if (!userDoc.exists) {
        throw Exception('Doctor not found');
      }
      
      final user = UserModel.fromFirestore(userDoc);
      
      // Then, get doctor details
      final doctorDoc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();
      
      DoctorModel doctor;
      
      if (doctorDoc.exists) {
        doctor = DoctorModel.fromFirestore(doctorDoc);
        
        // Combine user data with doctor data
        doctor = doctor.copyWith(
          name: user.displayName ?? 'Dr.',
          profileImageUrl: user.profileImageUrl,
        );
      } else {
        // Create a basic doctor model from user data
        doctor = DoctorModel(
          id: user.uid,
          name: user.displayName ?? 'Dr.',
          specialization: 'General Physician',
          profileImageUrl: user.profileImageUrl,
        );
      }
      
      _selectedDoctor = doctor;
      _setLoading(false);
      
      return doctor;
    } catch (e) {
      _setError('Failed to get doctor: $e');
      return null;
    }
  }
  
  // Filter doctors by specialization
  List<DoctorModel> filterBySpecialization(String specialization) {
    if (specialization.isEmpty) {
      return _doctors;
    }
    
    return _doctors
        .where((doctor) => doctor.specialization.toLowerCase()
            .contains(specialization.toLowerCase()))
        .toList();
  }
  
  // Search doctors by name
  List<DoctorModel> searchByName(String query) {
    if (query.isEmpty) {
      return _doctors;
    }
    
    return _doctors
        .where((doctor) => doctor.name.toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }
  
  // Set selected doctor
  void selectDoctor(DoctorModel doctor) {
    _selectedDoctor = doctor;
    notifyListeners();
  }
  
  // Clear selected doctor
  void clearSelectedDoctor() {
    _selectedDoctor = null;
    notifyListeners();
  }
  
  // Helper methods
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
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  patient,
  doctor,
  clinic
}

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;
  
  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });
  
  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      role: _parseRole(data['role']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
  
  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
  
  // Parse role from string
  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'doctor':
        return UserRole.doctor;
      case 'clinic':
        return UserRole.clinic;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }
  
  // Check if user is a patient
  bool get isPatient => role == UserRole.patient;
  
  // Check if user is a doctor
  bool get isDoctor => role == UserRole.doctor;
  
  // Check if user is a clinic
  bool get isClinic => role == UserRole.clinic;
} 
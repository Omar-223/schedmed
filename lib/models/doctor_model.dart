import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String? bio;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final int experience;
  final List<String> availableDays;
  final Map<String, List<String>> availableTimeSlots;
  final bool isAvailable;
  
  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    this.bio,
    this.profileImageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.experience = 0,
    this.availableDays = const [],
    this.availableTimeSlots = const {},
    this.isAvailable = true,
  });
  
  // Create from Firestore document
  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse available time slots
    Map<String, List<String>> timeSlots = {};
    if (data['availableTimeSlots'] != null) {
      final Map<String, dynamic> rawTimeSlots = data['availableTimeSlots'];
      rawTimeSlots.forEach((day, slots) {
        if (slots is List) {
          timeSlots[day] = List<String>.from(slots);
        }
      });
    }
    
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      bio: data['bio'],
      profileImageUrl: data['profileImageUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      experience: data['experience'] ?? 0,
      availableDays: data['availableDays'] != null 
          ? List<String>.from(data['availableDays']) 
          : [],
      availableTimeSlots: timeSlots,
      isAvailable: data['isAvailable'] ?? true,
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialization': specialization,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'experience': experience,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
      'isAvailable': isAvailable,
    };
  }
  
  // Create a copy with updated fields
  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialization,
    String? bio,
    String? profileImageUrl,
    double? rating,
    int? reviewCount,
    int? experience,
    List<String>? availableDays,
    Map<String, List<String>>? availableTimeSlots,
    bool? isAvailable,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experience: experience ?? this.experience,
      availableDays: availableDays ?? this.availableDays,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
} 
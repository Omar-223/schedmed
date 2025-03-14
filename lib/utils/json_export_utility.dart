import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Utility class to export sample data as JSON for Firestore
class JsonExportUtility {
  /// Convert a Timestamp to a JSON-friendly format
  static Map<String, dynamic> _timestampToJson(Timestamp timestamp) {
    return {
      '_seconds': timestamp.seconds,
      '_nanoseconds': timestamp.nanoseconds,
    };
  }
  
  /// Generate sample appointment data as JSON
  static String generateSampleAppointmentsJson() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    // Sample data
    final List<Map<String, dynamic>> appointments = [
      {
        "id": "appointment_001",
        "patientId": "patient_id_1",
        "patientName": "John Doe",
        "doctorId": "doctor_id_1",
        "doctorName": "Dr. Sarah Johnson",
        "doctorSpecialty": "Cardiology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day + 7))),
        "timeSlot": "10:00",
        "reasonForVisit": "Chest pain and shortness of breath",
        "status": "scheduled",
        "createdAt": _timestampToJson(Timestamp.now()),
        "notes": null
      },
      {
        "id": "appointment_002",
        "patientId": "patient_id_2",
        "patientName": "Jane Smith",
        "doctorId": "doctor_id_2",
        "doctorName": "Dr. Michael Chen",
        "doctorSpecialty": "Dermatology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day + 6))),
        "timeSlot": "10:00",
        "reasonForVisit": "Skin rash on arms and neck",
        "status": "scheduled",
        "createdAt": _timestampToJson(Timestamp.now()),
        "notes": null
      },
      {
        "id": "appointment_003",
        "patientId": "patient_id_3",
        "patientName": "Robert Johnson",
        "doctorId": "doctor_id_3",
        "doctorName": "Dr. Emily Rodriguez",
        "doctorSpecialty": "Neurology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day + 5))),
        "timeSlot": "10:00",
        "reasonForVisit": "Persistent headache for the past week",
        "status": "scheduled",
        "createdAt": _timestampToJson(Timestamp.now()),
        "notes": null
      },
      {
        "id": "appointment_004",
        "patientId": "patient_id_4",
        "patientName": "Maria Garcia",
        "doctorId": "doctor_id_4",
        "doctorName": "Dr. David Kim",
        "doctorSpecialty": "Orthopedics",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day + 4))),
        "timeSlot": "10:00",
        "reasonForVisit": "Joint pain in knees",
        "status": "scheduled",
        "createdAt": _timestampToJson(Timestamp.now()),
        "notes": null
      },
      {
        "id": "appointment_005",
        "patientId": "patient_id_5",
        "patientName": "James Wilson",
        "doctorId": "doctor_id_5",
        "doctorName": "Dr. Jessica Patel",
        "doctorSpecialty": "Pediatrics",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day + 3))),
        "timeSlot": "10:00",
        "reasonForVisit": "Annual check-up",
        "status": "scheduled",
        "createdAt": _timestampToJson(Timestamp.now()),
        "notes": null
      },
      {
        "id": "appointment_006",
        "patientId": "patient_id_1",
        "patientName": "John Doe",
        "doctorId": "doctor_id_2",
        "doctorName": "Dr. Michael Chen",
        "doctorSpecialty": "Dermatology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 3))),
        "timeSlot": "10:00",
        "reasonForVisit": "Skin rash follow-up",
        "status": "completed",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 10))),
        "notes": "Patient was seen and treated. Prescribed topical cream for rash."
      },
      {
        "id": "appointment_007",
        "patientId": "patient_id_2",
        "patientName": "Jane Smith",
        "doctorId": "doctor_id_3",
        "doctorName": "Dr. Emily Rodriguez",
        "doctorSpecialty": "Neurology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 4))),
        "timeSlot": "10:00",
        "reasonForVisit": "Migraine consultation",
        "status": "completed",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 11))),
        "notes": "Patient was seen and treated. Prescribed medication for migraines."
      },
      {
        "id": "appointment_008",
        "patientId": "patient_id_3",
        "patientName": "Robert Johnson",
        "doctorId": "doctor_id_4",
        "doctorName": "Dr. David Kim",
        "doctorSpecialty": "Orthopedics",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 5))),
        "timeSlot": "10:00",
        "reasonForVisit": "Back pain evaluation",
        "status": "completed",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 12))),
        "notes": "Patient was seen and treated. Recommended physical therapy."
      },
      {
        "id": "appointment_009",
        "patientId": "patient_id_4",
        "patientName": "Maria Garcia",
        "doctorId": "doctor_id_5",
        "doctorName": "Dr. Jessica Patel",
        "doctorSpecialty": "Pediatrics",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 6))),
        "timeSlot": "10:00",
        "reasonForVisit": "Child's vaccination",
        "status": "completed",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 13))),
        "notes": "Patient was seen and treated. Vaccination administered."
      },
      {
        "id": "appointment_010",
        "patientId": "patient_id_5",
        "patientName": "James Wilson",
        "doctorId": "doctor_id_1",
        "doctorName": "Dr. Sarah Johnson",
        "doctorSpecialty": "Cardiology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 7))),
        "timeSlot": "10:00",
        "reasonForVisit": "Heart palpitations",
        "status": "completed",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 14))),
        "notes": "Patient was seen and treated. ECG performed, results normal."
      },
      {
        "id": "appointment_011",
        "patientId": "patient_id_1",
        "patientName": "John Doe",
        "doctorId": "doctor_id_3",
        "doctorName": "Dr. Emily Rodriguez",
        "doctorSpecialty": "Neurology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 8))),
        "timeSlot": "10:00",
        "reasonForVisit": "Dizziness and vertigo",
        "status": "cancelled",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 15))),
        "notes": null
      },
      {
        "id": "appointment_012",
        "patientId": "patient_id_2",
        "patientName": "Jane Smith",
        "doctorId": "doctor_id_4",
        "doctorName": "Dr. David Kim",
        "doctorSpecialty": "Orthopedics",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 9))),
        "timeSlot": "10:00",
        "reasonForVisit": "Wrist pain after fall",
        "status": "cancelled",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 16))),
        "notes": null
      },
      {
        "id": "appointment_013",
        "patientId": "patient_id_3",
        "patientName": "Robert Johnson",
        "doctorId": "doctor_id_5",
        "doctorName": "Dr. Jessica Patel",
        "doctorSpecialty": "Pediatrics",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 10))),
        "timeSlot": "10:00",
        "reasonForVisit": "Child's fever",
        "status": "cancelled",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 17))),
        "notes": null
      },
      {
        "id": "appointment_014",
        "patientId": "patient_id_4",
        "patientName": "Maria Garcia",
        "doctorId": "doctor_id_1",
        "doctorName": "Dr. Sarah Johnson",
        "doctorSpecialty": "Cardiology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day + 8))),
        "timeSlot": "10:00",
        "reasonForVisit": "High blood pressure monitoring",
        "status": "scheduled",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 2))),
        "notes": null
      },
      {
        "id": "appointment_015",
        "patientId": "patient_id_5",
        "patientName": "James Wilson",
        "doctorId": "doctor_id_2",
        "doctorName": "Dr. Michael Chen",
        "doctorSpecialty": "Dermatology",
        "appointmentDate": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day + 9))),
        "timeSlot": "10:00",
        "reasonForVisit": "Mole examination",
        "status": "scheduled",
        "createdAt": _timestampToJson(Timestamp.fromDate(DateTime(now.year, now.month, now.day - 1))),
        "notes": null
      }
    ];
    
    // Convert to JSON string with pretty printing
    return JsonEncoder.withIndent('  ').convert(appointments);
  }
  
  /// Generate sample doctors data as JSON
  static String generateSampleDoctorsJson() {
    // Sample data
    final List<Map<String, dynamic>> doctors = [
      {
        "id": "doctor_id_1",
        "name": "Dr. Sarah Johnson",
        "specialty": "Cardiology",
        "bio": "Experienced cardiologist with over 15 years of practice.",
        "imageUrl": "https://randomuser.me/api/portraits/women/1.jpg",
        "rating": 4.8,
        "reviewCount": 120,
        "availableDays": ["Monday", "Tuesday", "Wednesday", "Friday"],
        "availableTimeSlots": ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00"]
      },
      {
        "id": "doctor_id_2",
        "name": "Dr. Michael Chen",
        "specialty": "Dermatology",
        "bio": "Board-certified dermatologist specializing in skin conditions and cosmetic procedures.",
        "imageUrl": "https://randomuser.me/api/portraits/men/2.jpg",
        "rating": 4.7,
        "reviewCount": 95,
        "availableDays": ["Monday", "Wednesday", "Thursday", "Friday"],
        "availableTimeSlots": ["09:00", "10:00", "11:00", "14:00", "15:00"]
      },
      {
        "id": "doctor_id_3",
        "name": "Dr. Emily Rodriguez",
        "specialty": "Neurology",
        "bio": "Neurologist with expertise in headaches, seizures, and movement disorders.",
        "imageUrl": "https://randomuser.me/api/portraits/women/3.jpg",
        "rating": 4.9,
        "reviewCount": 150,
        "availableDays": ["Tuesday", "Wednesday", "Thursday", "Friday"],
        "availableTimeSlots": ["08:00", "09:00", "10:00", "11:00", "13:00", "14:00", "15:00"]
      },
      {
        "id": "doctor_id_4",
        "name": "Dr. David Kim",
        "specialty": "Orthopedics",
        "bio": "Orthopedic surgeon specializing in sports injuries and joint replacements.",
        "imageUrl": "https://randomuser.me/api/portraits/men/4.jpg",
        "rating": 4.6,
        "reviewCount": 110,
        "availableDays": ["Monday", "Tuesday", "Thursday", "Friday"],
        "availableTimeSlots": ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00"]
      },
      {
        "id": "doctor_id_5",
        "name": "Dr. Jessica Patel",
        "specialty": "Pediatrics",
        "bio": "Compassionate pediatrician dedicated to children's health and development.",
        "imageUrl": "https://randomuser.me/api/portraits/women/5.jpg",
        "rating": 4.9,
        "reviewCount": 200,
        "availableDays": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
        "availableTimeSlots": ["08:00", "09:00", "10:00", "11:00", "13:00", "14:00", "15:00", "16:00"]
      }
    ];
    
    // Convert to JSON string with pretty printing
    return JsonEncoder.withIndent('  ').convert(doctors);
  }
  
  /// Generate sample patients data as JSON
  static String generateSamplePatientsJson() {
    // Sample data
    final List<Map<String, dynamic>> patients = [
      {
        "id": "patient_id_1",
        "name": "John Doe",
        "email": "john.doe@example.com",
        "phoneNumber": "+1234567890",
        "dateOfBirth": _timestampToJson(Timestamp.fromDate(DateTime(1985, 5, 15))),
        "gender": "male",
        "address": "123 Main St, Anytown, USA",
        "medicalHistory": [
          "Hypertension",
          "Allergies: Penicillin"
        ],
        "insuranceProvider": "HealthPlus",
        "insuranceNumber": "HP12345678"
      },
      {
        "id": "patient_id_2",
        "name": "Jane Smith",
        "email": "jane.smith@example.com",
        "phoneNumber": "+1987654321",
        "dateOfBirth": _timestampToJson(Timestamp.fromDate(DateTime(1990, 8, 22))),
        "gender": "female",
        "address": "456 Oak Ave, Somewhere, USA",
        "medicalHistory": [
          "Asthma",
          "Allergies: Shellfish"
        ],
        "insuranceProvider": "MediCare Plus",
        "insuranceNumber": "MC87654321"
      },
      {
        "id": "patient_id_3",
        "name": "Robert Johnson",
        "email": "robert.johnson@example.com",
        "phoneNumber": "+1122334455",
        "dateOfBirth": _timestampToJson(Timestamp.fromDate(DateTime(1978, 3, 10))),
        "gender": "male",
        "address": "789 Pine St, Elsewhere, USA",
        "medicalHistory": [
          "Diabetes Type 2",
          "High Cholesterol"
        ],
        "insuranceProvider": "HealthGuard",
        "insuranceNumber": "HG11223344"
      },
      {
        "id": "patient_id_4",
        "name": "Maria Garcia",
        "email": "maria.garcia@example.com",
        "phoneNumber": "+1556677889",
        "dateOfBirth": _timestampToJson(Timestamp.fromDate(DateTime(1995, 11, 28))),
        "gender": "female",
        "address": "101 Maple Dr, Nowhere, USA",
        "medicalHistory": [
          "Migraines",
          "Allergies: Pollen"
        ],
        "insuranceProvider": "CarePlus",
        "insuranceNumber": "CP55667788"
      },
      {
        "id": "patient_id_5",
        "name": "James Wilson",
        "email": "james.wilson@example.com",
        "phoneNumber": "+1998877665",
        "dateOfBirth": _timestampToJson(Timestamp.fromDate(DateTime(1982, 7, 4))),
        "gender": "male",
        "address": "202 Cedar Ln, Anywhere, USA",
        "medicalHistory": [
          "Arthritis",
          "Allergies: None"
        ],
        "insuranceProvider": "HealthFirst",
        "insuranceNumber": "HF99887766"
      }
    ];
    
    // Convert to JSON string with pretty printing
    return JsonEncoder.withIndent('  ').convert(patients);
  }
} 
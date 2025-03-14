import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedmed/services/appointment_service.dart';
import 'package:schedmed/utils/firestore_schema.dart';

/// Utility class to load sample data into Firestore
class SampleDataLoader {
  static final AppointmentService _appointmentService = AppointmentService();
  
  /// Initialize Firestore and load sample data
  static Future<void> initializeFirestoreWithSampleData() async {
    try {
      // Initialize Firestore schema
      await FirestoreSchema.initializeFirestore();
      
      // Load sample appointments
      await loadSampleAppointments();
      
      print('Firestore initialized with sample data');
    } catch (e) {
      print('Error initializing Firestore with sample data: $e');
      rethrow;
    }
  }
  
  /// Load sample appointments into Firestore
  static Future<void> loadSampleAppointments() async {
    try {
      await _appointmentService.addSampleAppointments(_sampleAppointmentsData);
      print('Sample appointments loaded successfully');
    } catch (e) {
      print('Error loading sample appointments: $e');
      rethrow;
    }
  }
  
  /// Sample appointments data
  static final List<Map<String, dynamic>> _sampleAppointmentsData = [
    {
      "id": "appointment_001",
      "patientId": "patient_id_1",
      "patientName": "John Doe",
      "doctorId": "doctor_id_1",
      "doctorName": "Dr. Sarah Johnson",
      "doctorSpecialty": "Cardiology",
      "appointmentDate": Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
      "timeSlot": "10:00",
      "reasonForVisit": "Chest pain and shortness of breath",
      "status": "scheduled",
      "createdAt": Timestamp.now(),
      "notes": null
    },
    {
      "id": "appointment_002",
      "patientId": "patient_id_2",
      "patientName": "Jane Smith",
      "doctorId": "doctor_id_2",
      "doctorName": "Dr. Michael Chen",
      "doctorSpecialty": "Dermatology",
      "appointmentDate": Timestamp.fromDate(DateTime.now().add(Duration(days: 6))),
      "timeSlot": "10:00",
      "reasonForVisit": "Skin rash on arms and neck",
      "status": "scheduled",
      "createdAt": Timestamp.now(),
      "notes": null
    },
    {
      "id": "appointment_003",
      "patientId": "patient_id_3",
      "patientName": "Robert Johnson",
      "doctorId": "doctor_id_3",
      "doctorName": "Dr. Emily Rodriguez",
      "doctorSpecialty": "Neurology",
      "appointmentDate": Timestamp.fromDate(DateTime.now().add(Duration(days: 5))),
      "timeSlot": "10:00",
      "reasonForVisit": "Persistent headache for the past week",
      "status": "scheduled",
      "createdAt": Timestamp.now(),
      "notes": null
    },
    {
      "id": "appointment_004",
      "patientId": "patient_id_4",
      "patientName": "Maria Garcia",
      "doctorId": "doctor_id_4",
      "doctorName": "Dr. David Kim",
      "doctorSpecialty": "Orthopedics",
      "appointmentDate": Timestamp.fromDate(DateTime.now().add(Duration(days: 4))),
      "timeSlot": "10:00",
      "reasonForVisit": "Joint pain in knees",
      "status": "scheduled",
      "createdAt": Timestamp.now(),
      "notes": null
    },
    {
      "id": "appointment_005",
      "patientId": "patient_id_5",
      "patientName": "James Wilson",
      "doctorId": "doctor_id_5",
      "doctorName": "Dr. Jessica Patel",
      "doctorSpecialty": "Pediatrics",
      "appointmentDate": Timestamp.fromDate(DateTime.now().add(Duration(days: 3))),
      "timeSlot": "10:00",
      "reasonForVisit": "Annual check-up",
      "status": "scheduled",
      "createdAt": Timestamp.now(),
      "notes": null
    },
    {
      "id": "appointment_006",
      "patientId": "patient_id_1",
      "patientName": "John Doe",
      "doctorId": "doctor_id_2",
      "doctorName": "Dr. Michael Chen",
      "doctorSpecialty": "Dermatology",
      "appointmentDate": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
      "timeSlot": "10:00",
      "reasonForVisit": "Skin rash follow-up",
      "status": "completed",
      "createdAt": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 10))),
      "notes": "Patient was seen and treated. Prescribed topical cream for rash."
    },
    {
      "id": "appointment_007",
      "patientId": "patient_id_2",
      "patientName": "Jane Smith",
      "doctorId": "doctor_id_3",
      "doctorName": "Dr. Emily Rodriguez",
      "doctorSpecialty": "Neurology",
      "appointmentDate": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 4))),
      "timeSlot": "10:00",
      "reasonForVisit": "Migraine consultation",
      "status": "completed",
      "createdAt": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 11))),
      "notes": "Patient was seen and treated. Prescribed medication for migraines."
    },
    {
      "id": "appointment_008",
      "patientId": "patient_id_3",
      "patientName": "Robert Johnson",
      "doctorId": "doctor_id_4",
      "doctorName": "Dr. David Kim",
      "doctorSpecialty": "Orthopedics",
      "appointmentDate": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5))),
      "timeSlot": "10:00",
      "reasonForVisit": "Back pain evaluation",
      "status": "completed",
      "createdAt": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 12))),
      "notes": "Patient was seen and treated. Recommended physical therapy."
    },
    {
      "id": "appointment_009",
      "patientId": "patient_id_4",
      "patientName": "Maria Garcia",
      "doctorId": "doctor_id_5",
      "doctorName": "Dr. Jessica Patel",
      "doctorSpecialty": "Pediatrics",
      "appointmentDate": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 6))),
      "timeSlot": "10:00",
      "reasonForVisit": "Child's vaccination",
      "status": "completed",
      "createdAt": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 13))),
      "notes": "Patient was seen and treated. Vaccination administered."
    },
    {
      "id": "appointment_010",
      "patientId": "patient_id_5",
      "patientName": "James Wilson",
      "doctorId": "doctor_id_1",
      "doctorName": "Dr. Sarah Johnson",
      "doctorSpecialty": "Cardiology",
      "appointmentDate": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7))),
      "timeSlot": "10:00",
      "reasonForVisit": "Heart palpitations",
      "status": "completed",
      "createdAt": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 14))),
      "notes": "Patient was seen and treated. ECG performed, results normal."
    },
    {
      "id": "appointment_011",
      "patientId": "patient_id_1",
      "patientName": "John Doe",
      "doctorId": "doctor_id_3",
      "doctorName": "Dr. Emily Rodriguez",
      "doctorSpecialty": "Neurology",
      "appointmentDate": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 8))),
      "timeSlot": "10:00",
      "reasonForVisit": "Dizziness and vertigo",
      "status": "cancelled",
      "createdAt": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 15))),
      "notes": null
    },
    {
      "id": "appointment_012",
      "patientId": "patient_id_2",
      "patientName": "Jane Smith",
      "doctorId": "doctor_id_4",
      "doctorName": "Dr. David Kim",
      "doctorSpecialty": "Orthopedics",
      "appointmentDate": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 9))),
      "timeSlot": "10:00",
      "reasonForVisit": "Wrist pain after fall",
      "status": "cancelled",
      "createdAt": Timestamp.fromDate(DateTime.now().subtract(Duration(days: 16))),
      "notes": null
    }
  ];
} 
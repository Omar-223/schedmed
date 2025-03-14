import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedmed/models/appointment_model.dart';

/// Utility class to manage Firestore schema and initialization
class FirestoreSchema {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Collection names as constants to ensure consistency
  static const String USERS_COLLECTION = 'users';
  static const String APPOINTMENTS_COLLECTION = 'appointments';
  static const String DOCTORS_COLLECTION = 'doctors';
  
  /// Initialize Firestore collections and any default data
  static Future<void> initializeFirestore() async {
    // This method doesn't actually create collections in Firestore
    // Collections are created automatically when the first document is added
    // But this method can be used to set up default data or validate existing data
    
    try {
      // Check if appointments collection exists by trying to get a document
      final appointmentCheck = await _firestore.collection(APPOINTMENTS_COLLECTION).limit(1).get();
      
      // Log initialization status
      print('Firestore initialized. Appointments collection exists: ${appointmentCheck.docs.isNotEmpty}');
    } catch (e) {
      print('Error initializing Firestore: $e');
      rethrow;
    }
  }
  
  /// Get a reference to the appointments collection
  static CollectionReference get appointmentsCollection => 
      _firestore.collection(APPOINTMENTS_COLLECTION);
  
  /// Get a reference to the users collection
  static CollectionReference get usersCollection => 
      _firestore.collection(USERS_COLLECTION);
      
  /// Get a reference to the doctors collection
  static CollectionReference get doctorsCollection => 
      _firestore.collection(DOCTORS_COLLECTION);
  
  /// Create a new appointment document with the correct schema
  static Future<String> createAppointmentWithSchema({
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
      // Create a document reference with auto-generated ID
      final docRef = appointmentsCollection.doc();
      
      // Prepare the appointment data with the correct schema
      final appointmentData = {
        'id': docRef.id,
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorSpecialty': doctorSpecialty,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'timeSlot': timeSlot,
        'reasonForVisit': reasonForVisit,
        'notes': notes,
        'status': 'scheduled',
        'createdAt': Timestamp.now(),
      };
      
      // Set the document data
      await docRef.set(appointmentData);
      
      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }
  
  /// Add sample data to Firestore for testing
  static Future<void> addSampleAppointments(List<Map<String, dynamic>> sampleData) async {
    try {
      // Use a batch to add multiple documents at once
      final batch = _firestore.batch();
      
      for (final appointmentData in sampleData) {
        // Create a document reference with the ID from the sample data
        final docRef = appointmentsCollection.doc(appointmentData['id']);
        
        // Add the document to the batch
        batch.set(docRef, appointmentData);
      }
      
      // Commit the batch
      await batch.commit();
      
      print('Sample appointments added successfully');
    } catch (e) {
      print('Error adding sample appointments: $e');
      rethrow;
    }
  }
} 
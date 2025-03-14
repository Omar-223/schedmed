import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedmed/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _usersCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get all patients
  Stream<List<UserModel>> getAllPatients() {
    return _usersCollection
        .where('role', isEqualTo: 'patient')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get all clinics
  Stream<List<UserModel>> getAllClinics() {
    return _usersCollection
        .where('role', isEqualTo: 'clinic')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      throw Exception('User not found');
    } catch (e) {
      rethrow;
    }
  }

  // Update user details
  Future<void> updateUser(String userId, {
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (name != null) {
        updateData['name'] = name;
      }
      
      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }
      
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }
      
      if (updateData.isNotEmpty) {
        await _usersCollection.doc(userId).update(updateData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Deactivate user account
  Future<void> deactivateUser(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'isActive': false,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Activate user account
  Future<void> activateUser(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'isActive': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get total number of patients
  Future<int> getTotalPatients() async {
    try {
      QuerySnapshot snapshot = await _usersCollection
          .where('role', isEqualTo: 'patient')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  // Search users by name
  Stream<List<UserModel>> searchUsersByName(String query) {
    // Convert query to lowercase for case-insensitive search
    String searchQuery = query.toLowerCase();
    
    return _usersCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .where((user) => user.displayName?.toLowerCase().contains(searchQuery) ?? false)
              .toList();
        });
  }
} 
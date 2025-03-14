import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schedmed/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  UserRole get userRole => _user?.role ?? UserRole.patient;
  
  // Constructor
  AuthProvider() {
    print("AuthProvider initialized");
    _init();
  }
  
  // Initialize the provider
  Future<void> _init() async {
    print("AuthProvider _init called");
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      print("Current user found: ${_firebaseUser!.email}");
      await _fetchUserData();
    }
    
    _auth.authStateChanges().listen((User? user) async {
      print("Auth state changed: ${user?.email}");
      _firebaseUser = user;
      
      if (user != null) {
        await _fetchUserData();
      } else {
        _user = null;
      }
      
      notifyListeners();
    });
  }
  
  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (_firebaseUser == null) return;
    
    try {
      _setLoading(true);
      
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        print("User data fetched: ${_user?.displayName}");
      } else {
        print("User document does not exist in Firestore");
      }
      
      _setLoading(false);
    } catch (e) {
      print("Error fetching user data: $e");
      _setError('Failed to fetch user data: $e');
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      clearError();
      
      print("Attempting to sign in with email: $email");
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _firebaseUser = userCredential.user;
      print("Sign in successful: ${_firebaseUser?.email}");
      
      await _fetchUserData();
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      
      print("Sign in error: $errorMessage");
      _setError(errorMessage);
      return false;
    } catch (e) {
      print("Sign in error: $e");
      _setError('Failed to sign in: $e');
      return false;
    }
  }
  
  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String phoneNumber,
    UserRole role,
  ) async {
    try {
      _setLoading(true);
      
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _firebaseUser = userCredential.user;
      
      // Update display name
      await _firebaseUser!.updateDisplayName(displayName);
      
      // Create user document in Firestore
      final userModel = UserModel(
        uid: _firebaseUser!.uid,
        email: email,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(_firebaseUser!.uid).set(
        userModel.toFirestore(),
      );
      
      _user = userModel;
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('Failed to register: $e');
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      print("AuthProvider: Signing out user");
      await _auth.signOut();
      _user = null;
      _firebaseUser = null;
      print("AuthProvider: User signed out successfully");
      notifyListeners();
    } catch (e) {
      print("AuthProvider: Error signing out: $e");
      _setError('Failed to sign out: $e');
      throw e; // Rethrow to allow handling in UI
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('Failed to reset password: $e');
      return false;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      if (_firebaseUser == null || _user == null) {
        _setError('User not authenticated');
        return false;
      }
      
      _setLoading(true);
      
      // Update display name in Firebase Auth if provided
      if (displayName != null && displayName.isNotEmpty) {
        await _firebaseUser!.updateDisplayName(displayName);
      }
      
      // Update user document in Firestore
      final updates = <String, dynamic>{};
      
      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      
      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
      }
      
      if (address != null) {
        updates['address'] = address;
      }
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_firebaseUser!.uid).update(updates);
        
        // Update local user model
        _user = _user!.copyWith(
          displayName: displayName ?? _user!.displayName,
          phoneNumber: phoneNumber ?? _user!.phoneNumber,
          address: address ?? _user!.address,
        );
        
        notifyListeners();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }
  
  // Update password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      if (_firebaseUser == null || _user == null) {
        _setError('User not authenticated');
        return false;
      }
      
      _setLoading(true);
      
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _firebaseUser!.email!,
        password: currentPassword,
      );
      
      await _firebaseUser!.reauthenticateWithCredential(credential);
      
      // Update password
      await _firebaseUser!.updatePassword(newPassword);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect.';
          break;
        case 'weak-password':
          errorMessage = 'The new password is too weak.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('Failed to update password: $e');
      return false;
    }
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
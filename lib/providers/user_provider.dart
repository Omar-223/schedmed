import 'package:flutter/material.dart';
import 'package:schedmed/models/user_model.dart';
import 'package:schedmed/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  List<UserModel> _users = [];
  List<UserModel> _patients = [];
  List<UserModel> _admins = [];
  UserModel? _selectedUser;
  bool _isLoading = false;
  String? _error;
  int _totalPatients = 0;
  
  // Getters
  List<UserModel> get users => _users;
  List<UserModel> get patients => _patients;
  List<UserModel> get admins => _admins;
  UserModel? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPatients => _totalPatients;
  
  // Load all users
  void loadAllUsers() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userService.getAllUsers().listen(
        (users) {
          _users = users;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load all patients
  void loadAllPatients() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userService.getAllPatients().listen(
        (patients) {
          _patients = patients;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load all admins
  void loadAllAdmins() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userService.getAllAdmins().listen(
        (admins) {
          _admins = admins;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get user by ID
  Future<void> getUserById(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedUser = await _userService.getUserById(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set selected user
  void setSelectedUser(UserModel user) {
    _selectedUser = user;
    notifyListeners();
  }
  
  // Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
  
  // Update user details
  Future<bool> updateUser(String userId, {
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _userService.updateUser(
        userId,
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Deactivate user account
  Future<bool> deactivateUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _userService.deactivateUser(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Activate user account
  Future<bool> activateUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _userService.activateUser(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get total number of patients
  Future<void> getTotalPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _totalPatients = await _userService.getTotalPatients();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Search users by name
  void searchUsersByName(String query) {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userService.searchUsersByName(query).listen(
        (users) {
          _users = users;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 
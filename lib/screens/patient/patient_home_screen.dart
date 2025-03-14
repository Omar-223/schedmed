import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/screens/auth/login_screen.dart';
import 'package:schedmed/screens/patient/patient_appointments_screen.dart';
import 'package:schedmed/screens/patient/patient_book_appointment_screen.dart';
import 'package:schedmed/screens/patient/patient_dashboard_screen.dart';
import 'package:schedmed/screens/patient/patient_profile_screen.dart';
import 'package:schedmed/utils/theme.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  bool _isSigningOut = false;
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    print("PatientHomeScreen initialized");
    _loadData();
    _initScreens();
  }
  
  void _initScreens() {
    print("Initializing patient screens");
    _screens = [
      PatientDashboardScreen(
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const PatientAppointmentsScreen(),
      const PatientBookAppointmentScreen(),
      const PatientProfileScreen(),
    ];
  }
  
  Future<void> _loadData() async {
    print("Loading patient data");
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print("Current user: ${authProvider.user?.displayName}");
    
    if (authProvider.user != null) {
      // Load patient data
      // Load appointments
      print("User is authenticated, loading data");
    } else {
      print("User is not authenticated, should not be on this screen");
      // If somehow we got here without authentication, go back to login
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String title = _getTitle();
    
    // If user is not authenticated, show loading screen
    if (!authProvider.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isSigningOut ? null : _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Appointments';
      case 2:
        return 'Book Appointment';
      case 3:
        return 'Profile';
      default:
        return 'SchedMed';
    }
  }
  
  Future<void> _signOut() async {
    if (_isSigningOut) return;
    
    setState(() {
      _isSigningOut = true;
    });
    
    print("Signing out");
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.signOut();
      print("Sign out successful");
      
      if (context.mounted) {
        // Use pushAndRemoveUntil to clear the navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error signing out: $e");
      
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
 
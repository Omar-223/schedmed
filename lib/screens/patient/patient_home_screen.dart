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
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _initScreens();
  }
  
  void _initScreens() {
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      // Load patient data
      // Load appointments
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  
  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
 
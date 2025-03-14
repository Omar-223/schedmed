import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/screens/auth/login_screen.dart';
import 'package:schedmed/screens/patient/patient_home_screen.dart';
import 'package:schedmed/utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Use Future.delayed to ensure the widget is fully built before checking auth
    Future.delayed(Duration.zero, () {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Prevent multiple navigation attempts
    if (_isNavigating) return;
    _isNavigating = true;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Navigate directly based on authentication state
    if (authProvider.isAuthenticated) {
      print("User is authenticated, navigating to PatientHomeScreen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
      );
    } else {
      print("User is not authenticated, navigating to LoginScreen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(75),
                      ),
                      child: Center(
                        child: Text(
                          "S",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App name
                    const Text(
                      'SchedMed',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom section with tagline
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: [
                  const Text(
                    'Now your healthcare journey is in one place',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'and always within reach.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Loading indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
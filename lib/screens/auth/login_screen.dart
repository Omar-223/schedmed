import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/screens/auth/register_screen.dart';
import 'package:schedmed/screens/auth/reset_password_screen.dart';
import 'package:schedmed/screens/patient/patient_home_screen.dart';
import 'package:schedmed/utils/theme.dart';
import 'package:schedmed/widgets/custom_button.dart';
import 'package:schedmed/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isNavigating = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Prevent multiple login attempts
      if (_isNavigating) return;
      
      setState(() {
        _isNavigating = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      print("Attempting to sign in with email: ${_emailController.text.trim()}");
      
      final success = await authProvider.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      print("Sign in result: $success");
      print("Is authenticated: ${authProvider.isAuthenticated}");
      print("Current user: ${authProvider.user}");
      
      // If login was successful and we're still mounted, navigate to home screen
      if (success && mounted && authProvider.isAuthenticated) {
        print("Login successful, navigating to home screen");
        
        // Use Future.microtask to avoid calling setState during build
        Future.microtask(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
          );
        });
      } else {
        // Reset navigation flag if login failed
        if (mounted) {
          setState(() {
            _isNavigating = false;
          });
        }
      }
    }
  }

  Future<void> _loginAsClinic() async {
    if (_isNavigating) return;
    
    // Set email and password for clinic login (for demo purposes)
    _emailController.text = "clinic@example.com";
    _passwordController.text = "password123";
    await _login();
  }

  Future<void> _loginAsPatient() async {
    if (_isNavigating) return;
    
    // Set email and password for patient login (for demo purposes)
    _emailController.text = "patient@example.com";
    _passwordController.text = "password123";
    await _login();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "S",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'SchedMed',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to your account',
                          style: TextStyle(
                            color: AppTheme.textLightColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Sign in options
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Sign in as a Clinic',
                          onPressed: _loginAsClinic,
                          backgroundColor: AppTheme.primaryColor,
                          height: 56,
                          isLoading: _isNavigating && authProvider.isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Sign in as a Patient',
                          onPressed: _loginAsPatient,
                          isOutlined: true,
                          height: 56,
                          isLoading: _isNavigating && authProvider.isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    enabled: !_isNavigating,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: _isNavigating ? null : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    enabled: !_isNavigating,
                  ),
                  
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isNavigating ? null : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  
                  // Error message
                  if (authProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  
                  // Login button
                  CustomButton(
                    text: 'Login',
                    onPressed: _isNavigating ? () {} : () {
                      _login();
                    },
                    isLoading: authProvider.isLoading,
                    icon: Icons.login,
                  ),
                  const SizedBox(height: 24),
                  
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: AppTheme.textLightColor,
                        ),
                      ),
                      TextButton(
                        onPressed: _isNavigating ? null : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
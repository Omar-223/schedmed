import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedmed/providers/appointment_provider.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/providers/doctor_provider.dart';
import 'package:schedmed/screens/admin/sample_data_screen.dart';
import 'package:schedmed/screens/auth/splash_screen.dart';
import 'package:schedmed/utils/theme.dart';
import 'firebase_options.dart';

// Define route names as constants
class AppRoutes {
  static const String splash = '/';
  static const String sampleData = '/sample-data';
  // Add more routes as needed
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Catch any errors during initialization
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Run the app
    runApp(const MyApp());
  } catch (e) {
    print("Error initializing app: $e");
    // Show error screen if initialization fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize app: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        title: 'SchedMed',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.sampleData: (context) => const SampleDataScreen(),
        },
      ),
    );
  }
}

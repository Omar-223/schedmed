import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedmed/models/user_model.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/utils/theme.dart';
import 'package:schedmed/screens/auth/login_screen.dart';
import 'package:schedmed/screens/admin/sample_data_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({Key? key}) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  // Flag to show developer options
  bool _showDeveloperOptions = false;
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return const Center(
        child: Text('User not logged in'),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Hidden developer options toggle
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.primaryColor),
            onPressed: () {
              setState(() {
                _showDeveloperOptions = !_showDeveloperOptions;
              });
              if (_showDeveloperOptions) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Developer options enabled'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar and user info
            _buildProfileHeader(user),
            
            const SizedBox(height: 20),
            
            // Menu items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Information',
              trailing: const Icon(
                Icons.warning_rounded,
                color: AppTheme.warningColor,
              ),
              onTap: () {
                // Navigate to edit profile screen
              },
            ),
            
            _buildMenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'My Bookings',
              onTap: () {
                // Navigate to bookings screen
              },
            ),
            
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                // Navigate to settings screen
              },
            ),
            
            _buildMenuItem(
              icon: Icons.medication_outlined,
              title: 'Medications Schedule',
              onTap: () {
                // Navigate to medications schedule screen
              },
            ),
            
            // Developer options
            if (_showDeveloperOptions)
              _buildMenuItem(
                icon: Icons.developer_mode,
                title: 'Sample Data',
                textColor: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/sample-data');
                },
              ),
            
            _buildMenuItem(
              icon: Icons.logout_outlined,
              title: 'Log Out',
              textColor: Colors.blue,
              onTap: () async {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                if (shouldLogout == true) {
                  await authProvider.signOut();
                  
                  if (context.mounted) {
                    // Navigate to login screen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Profile image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _getInitials(user.displayName ?? 'User'),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      _getInitials(user.displayName ?? 'User'),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // User name
          Text(
            user.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Phone number
          Text(
            user.phoneNumber ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textLightColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? AppTheme.textColor,
          ),
        ),
        trailing: trailing ?? const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textLightColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: onTap,
      ),
    );
  }
  
  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (name.isNotEmpty) {
      return name[0];
    }
    return 'U';
  }

} 
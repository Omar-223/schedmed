import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:schedmed/models/appointment_model.dart';
import 'package:schedmed/providers/appointment_provider.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/screens/patient/patient_home_screen.dart';
import 'package:schedmed/utils/theme.dart';
import 'package:schedmed/widgets/appointment_card.dart';
import 'package:schedmed/widgets/dashboard_card.dart';

// Define a callback for tab navigation
typedef TabNavigationCallback = void Function(int tabIndex);

class PatientDashboardScreen extends StatefulWidget {
  final TabNavigationCallback? onTabChange;
  
  const PatientDashboardScreen({
    Key? key, 
    this.onTabChange,
  }) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    
    // Filter upcoming appointments
    final upcomingAppointments = appointmentProvider.patientAppointments
        .where((appointment) => 
            appointment.status == AppointmentStatus.scheduled && 
            appointment.appointmentDate.isAfter(DateTime.now()))
        .toList();
    
    // Sort by date
    upcomingAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    
    // Get next appointment
    final nextAppointment = upcomingAppointments.isNotEmpty ? upcomingAppointments.first : null;
    
    // Count total appointments
    final totalAppointments = appointmentProvider.patientAppointments.length;
    
    // Count completed appointments
    final completedAppointments = appointmentProvider.patientAppointments
        .where((appointment) => appointment.status == AppointmentStatus.completed)
        .length;
    
    // Count cancelled appointments
    final cancelledAppointments = appointmentProvider.patientAppointments
        .where((appointment) => appointment.status == AppointmentStatus.cancelled)
        .length;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: appointmentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (authProvider.user != null) {
                  appointmentProvider.loadPatientAppointments(authProvider.user!.uid);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Welcome message with improved styling
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                    Text(
                      'Welcome, ${authProvider.user?.displayName ?? 'Patient'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                            ],
                          ),
                        ),
                        // User avatar
                        GestureDetector(
                          onTap: () {
                            // Navigate to profile screen
                            if (widget.onTabChange != null) {
                              widget.onTabChange!(3); // Assuming profile is at index 3
                            }
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              _getInitials(authProvider.user?.displayName ?? 'User'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Stats cards with improved styling
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          title: 'Total Appointments',
                          value: totalAppointments.toString(),
                          icon: Icons.calendar_month,
                          color: AppTheme.primaryColor,
                          onTap: () {
                            // Navigate to appointments tab (index 1)
                            if (widget.onTabChange != null) {
                              widget.onTabChange!(1);
                            }
                          },
                        ),
                        _buildStatCard(
                          title: 'Upcoming',
                          value: upcomingAppointments.length.toString(),
                          icon: Icons.upcoming,
                          color: AppTheme.accentColor,
                          onTap: () {
                            // Navigate to appointments tab (index 1)
                            if (widget.onTabChange != null) {
                              widget.onTabChange!(1);
                            }
                          },
                        ),
                        _buildStatCard(
                          title: 'Completed',
                          value: completedAppointments.toString(),
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                          onTap: () {
                            // Navigate to appointments tab (index 1)
                            if (widget.onTabChange != null) {
                              widget.onTabChange!(1);
                            }
                          },
                        ),
                        _buildStatCard(
                          title: 'Cancelled',
                          value: cancelledAppointments.toString(),
                          icon: Icons.cancel,
                          color: AppTheme.errorColor,
                          onTap: () {
                            // Navigate to appointments tab (index 1)
                            if (widget.onTabChange != null) {
                              widget.onTabChange!(1);
                            }
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Next appointment section with improved styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    const Text(
                      'Next Appointment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        if (upcomingAppointments.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // Navigate to appointments tab (index 1)
                              if (widget.onTabChange != null) {
                                widget.onTabChange!(1);
                              }
                            },
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (nextAppointment != null)
                      _buildAppointmentCard(nextAppointment)
                    else
                      _buildEmptyAppointmentCard(),
                    
                    const SizedBox(height: 32),
                    
                    // Recent appointments section with improved styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Appointments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        if (appointmentProvider.patientAppointments.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // Navigate to appointments tab (index 1)
                            if (widget.onTabChange != null) {
                              widget.onTabChange!(1);
                            }
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (appointmentProvider.patientAppointments.isEmpty)
                      _buildEmptyRecentAppointments()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appointmentProvider.patientAppointments.length > 3
                            ? 3
                            : appointmentProvider.patientAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointmentProvider.patientAppointments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildAppointmentCard(appointment),
                          );
                        },
                      ),
                      
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final statusColor = appointment.status == AppointmentStatus.scheduled
        ? AppTheme.primaryColor
        : appointment.status == AppointmentStatus.completed
            ? AppTheme.successColor
            : AppTheme.errorColor;
            
    final statusText = appointment.status == AppointmentStatus.scheduled
        ? 'Scheduled'
        : appointment.status == AppointmentStatus.completed
            ? 'Completed'
            : 'Cancelled';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  appointment.status == AppointmentStatus.scheduled
                      ? Icons.calendar_today
                      : appointment.status == AppointmentStatus.completed
                          ? Icons.check_circle
                          : Icons.cancel,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorSpecialty ?? 'Appointment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctorName ?? 'Doctor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAppointmentDetail(
                  icon: Icons.calendar_today,
                  title: 'Date',
                  value: DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
                ),
              ),
              Expanded(
                child: _buildAppointmentDetail(
                  icon: Icons.access_time,
                  title: 'Time',
                  value: DateFormat('hh:mm a').format(appointment.appointmentDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (appointment.status == AppointmentStatus.scheduled)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelDialog(context, appointment);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to reschedule screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Reschedule'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildAppointmentDetail({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildEmptyAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No upcoming appointments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book an appointment to get started',
            style: TextStyle(
              color: AppTheme.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to book appointment tab (index 2)
                if (widget.onTabChange != null) {
                  widget.onTabChange!(2);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyRecentAppointments() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'No appointment history',
          style: TextStyle(
            color: AppTheme.textLightColor,
                ),
              ),
            ),
    );
  }

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () async {
              final appointmentProvider = Provider.of<AppointmentProvider>(
                context,
                listen: false,
              );
              
              await appointmentProvider.updateAppointmentStatus(
                appointment.id,
                AppointmentStatus.cancelled,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
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
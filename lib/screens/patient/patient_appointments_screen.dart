import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedmed/models/appointment_model.dart';
import 'package:schedmed/providers/appointment_provider.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/utils/theme.dart';
import 'package:schedmed/widgets/appointment_card.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    
    // Filter appointments by status
    final upcomingAppointments = appointmentProvider.patientAppointments
        .where((appointment) => 
            appointment.status == AppointmentStatus.scheduled && 
            appointment.appointmentDate.isAfter(DateTime.now()))
        .toList();
    
    final completedAppointments = appointmentProvider.patientAppointments
        .where((appointment) => appointment.status == AppointmentStatus.completed)
        .toList();
    
    final cancelledAppointments = appointmentProvider.patientAppointments
        .where((appointment) => appointment.status == AppointmentStatus.cancelled)
        .toList();
    
    // Sort by date
    upcomingAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    completedAppointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    cancelledAppointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    
    return Scaffold(
      body: appointmentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tab bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: [
                      Tab(
                        text: 'Upcoming (${upcomingAppointments.length})',
                        icon: const Icon(Icons.upcoming),
                      ),
                      Tab(
                        text: 'Completed (${completedAppointments.length})',
                        icon: const Icon(Icons.check_circle),
                      ),
                      Tab(
                        text: 'Cancelled (${cancelledAppointments.length})',
                        icon: const Icon(Icons.cancel),
                      ),
                    ],
                  ),
                ),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming appointments tab
                      _buildAppointmentsList(
                        upcomingAppointments,
                        'No upcoming appointments',
                        'Book an appointment to get started',
                        true,
                      ),
                      
                      // Completed appointments tab
                      _buildAppointmentsList(
                        completedAppointments,
                        'No completed appointments',
                        'Your completed appointments will appear here',
                        false,
                      ),
                      
                      // Cancelled appointments tab
                      _buildAppointmentsList(
                        cancelledAppointments,
                        'No cancelled appointments',
                        'Your cancelled appointments will appear here',
                        false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(
    List<AppointmentModel> appointments,
    String emptyTitle,
    String emptySubtitle,
    bool showActions,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user != null) {
          Provider.of<AppointmentProvider>(context, listen: false)
              .loadPatientAppointments(authProvider.user!.uid);
        }
      },
      child: appointments.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          emptySubtitle,
                          style: const TextStyle(
                            color: AppTheme.textLightColor,
                          ),
                        ),
                        if (showActions) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to book appointment screen
                              // Find the parent PatientHomeScreen and change the index
                              final scaffold = Scaffold.of(context);
                              final homeScreenState = context.findAncestorStateOfType<State>();
                              if (homeScreenState != null && 
                                  homeScreenState.toString().contains('_PatientHomeScreenState')) {
                                // Use Navigator to pop back to home screen
                                Navigator.of(context).pop();
                                // Then navigate to book appointment tab
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  if (scaffold.context.mounted) {
                                    // This is a workaround since we can't directly access _currentIndex
                                    // The parent screen should handle navigation to the book appointment tab
                                    ScaffoldMessenger.of(scaffold.context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please tap on the Book tab to schedule an appointment'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                });
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Book Appointment'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppointmentCard(
                    appointment: appointment,
                    onTap: () {
                      // Navigate to appointment details
                    },
                    onCancel: showActions && appointment.status == AppointmentStatus.scheduled
                        ? () {
                            // Show cancel confirmation dialog
                            _showCancelDialog(context, appointment);
                          }
                        : null,
                    onReschedule: showActions && appointment.status == AppointmentStatus.scheduled
                        ? () {
                            // Navigate to reschedule screen
                          }
                        : null,
                  ),
                );
              },
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
} 
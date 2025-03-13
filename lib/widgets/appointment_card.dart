import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedmed/models/appointment_model.dart';
import 'package:schedmed/utils/theme.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  
  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
    this.onCancel,
    this.onReschedule,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Format date and time
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    final formattedDate = dateFormat.format(appointment.appointmentDate);
    final formattedTime = timeFormat.format(appointment.appointmentDate);
    
    // Determine status color
    Color statusColor;
    IconData statusIcon;
    
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.schedule;
        break;
      case AppointmentStatus.completed:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              Row(
                children: [
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(appointment.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Show upcoming indicator if appointment is in the future
                  if (appointment.status == AppointmentStatus.scheduled &&
                      appointment.appointmentDate.isAfter(DateTime.now())) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTimeUntil(appointment.appointmentDate),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              const Divider(height: 24),
              
              // Doctor info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    radius: 24,
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${appointment.doctorName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorSpecialty ?? 'General Physician',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date and time
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Reason for visit
              if (appointment.reasonForVisit != null &&
                  appointment.reasonForVisit!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Reason: ${appointment.reasonForVisit}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Action buttons for scheduled appointments
              if (appointment.status == AppointmentStatus.scheduled &&
                  (onCancel != null || onReschedule != null)) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onReschedule != null)
                      OutlinedButton(
                        onPressed: onReschedule,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    if (onReschedule != null && onCancel != null)
                      const SizedBox(width: 8),
                    if (onCancel != null)
                      OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  
  String _getTimeUntil(DateTime appointmentDate) {
    final now = DateTime.now();
    final difference = appointmentDate.difference(now);
    
    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? 'Tomorrow'
          : 'In ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minutes';
    } else {
      return 'Now';
    }
  }
} 
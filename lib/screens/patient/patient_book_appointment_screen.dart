import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:schedmed/models/doctor_model.dart';
import 'package:schedmed/models/appointment_model.dart';
import 'package:schedmed/providers/auth_provider.dart';
import 'package:schedmed/providers/doctor_provider.dart';
import 'package:schedmed/providers/appointment_provider.dart';
import 'package:schedmed/utils/theme.dart';
import 'package:schedmed/widgets/doctor_card.dart';
import 'package:uuid/uuid.dart';

class PatientBookAppointmentScreen extends StatefulWidget {
  const PatientBookAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<PatientBookAppointmentScreen> createState() => _PatientBookAppointmentScreenState();
}

class _PatientBookAppointmentScreenState extends State<PatientBookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Booking steps
  int _currentStep = 0;
  
  // Selected values
  DoctorModel? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '';
  String _reasonForVisit = '';
  
  // Available time slots (would normally come from backend)
  final List<String> _availableTimeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM'
  ];
  
  @override
  void initState() {
    super.initState();
    // Load doctors when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).loadDoctors();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _buildStepper(),
    );
  }
  
  Widget _buildStepper() {
    return Stepper(
      type: StepperType.horizontal,
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep == 0 && _selectedDoctor == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a doctor')),
          );
          return;
        }
        
        if (_currentStep == 1 && _selectedTimeSlot.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a time slot')),
          );
          return;
        }
        
        if (_currentStep == 2) {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _bookAppointment();
          }
          return;
        }
        
        setState(() {
          _currentStep += 1;
        });
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() {
            _currentStep -= 1;
          });
        }
      },
      steps: [
        Step(
          title: const Text('Doctor'),
          content: _buildDoctorSelection(),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Date & Time'),
          content: _buildDateTimeSelection(),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Details'),
          content: _buildDetailsForm(),
          isActive: _currentStep >= 2,
        ),
      ],
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0)
                const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(_currentStep == 2 ? 'Book Now' : 'Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDoctorSelection() {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    
    if (doctorProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (doctorProvider.doctors.isEmpty) {
      return const Center(
        child: Text('No doctors available at the moment'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Doctor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: doctorProvider.doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctorProvider.doctors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: DoctorCard(
                doctor: doctor,
                selected: _selectedDoctor?.id == doctor.id,
                onTap: () {
                  setState(() {
                    _selectedDoctor = doctor;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selection
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Time slot selection
        const Text(
          'Select Time Slot',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTimeSlots.map((timeSlot) {
            final isSelected = _selectedTimeSlot == timeSlot;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeSlot = timeSlot;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  timeSlot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointment summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedDoctor != null) ...[
                  _buildSummaryItem(
                    'Doctor',
                    'Dr. ${_selectedDoctor!.name}',
                  ),
                  _buildSummaryItem(
                    'Specialization',
                    _selectedDoctor!.specialization,
                  ),
                ],
                _buildSummaryItem(
                  'Date',
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                ),
                _buildSummaryItem('Time', _selectedTimeSlot),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Reason for visit
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Reason for Visit',
              border: OutlineInputBorder(),
              hintText: 'Briefly describe your symptoms or reason for appointment',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter reason for visit';
              }
              return null;
            },
            onSaved: (value) {
              _reasonForVisit = value!;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _bookAppointment() async {
    if (_selectedDoctor == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    // Parse time slot to create DateTime
    final format = DateFormat('hh:mm a');
    final time = format.parse(_selectedTimeSlot);
    
    // Combine date and time
    final appointmentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
    
    // Create appointment model
    final appointment = AppointmentModel(
      id: const Uuid().v4(),
      patientId: authProvider.user!.uid,
      doctorId: _selectedDoctor!.id,
      appointmentDate: appointmentDateTime,
      reasonForVisit: _reasonForVisit,
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
    );
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Booking your appointment...'),
            ],
          ),
        ),
      );
      
      // Book appointment
      await appointmentProvider.bookAppointment(appointment);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Appointment Booked'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your appointment has been booked successfully!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Time: $_selectedTimeSlot',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Doctor: Dr. ${_selectedDoctor!.name}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to appointments screen
                  setState(() {
                    // Navigate to appointments tab
                    final homeScreenState = context.findAncestorStateOfType<State>();
                    if (homeScreenState != null) {
                      // Try to access _currentIndex using reflection
                      try {
                        final field = homeScreenState.runtimeType.toString().contains('PatientHomeScreenState') 
                            ? homeScreenState 
                            : null;
                        if (field != null) {
                          // Navigate to appointments tab (index 1)
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        // Fallback if reflection fails
                        Navigator.of(context).pop();
                      }
                    }
                  });
                },
                child: const Text('View My Appointments'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to book appointment: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
} 
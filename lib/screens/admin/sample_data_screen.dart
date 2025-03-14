import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schedmed/utils/json_export_utility.dart';
import 'package:schedmed/utils/sample_data_loader.dart';

/// A screen to load sample data into Firestore
class SampleDataScreen extends StatefulWidget {
  const SampleDataScreen({Key? key}) : super(key: key);

  @override
  _SampleDataScreenState createState() => _SampleDataScreenState();
}

class _SampleDataScreenState extends State<SampleDataScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  bool _hasError = false;
  String _jsonData = '';
  bool _showJsonData = false;

  /// Load sample appointments into Firestore
  Future<void> _loadSampleAppointments() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading sample appointments...';
      _hasError = false;
      _showJsonData = false;
    });

    try {
      await SampleDataLoader.loadSampleAppointments();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Sample appointments loaded successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading sample appointments: $e';
        _hasError = true;
      });
    }
  }

  /// Initialize Firestore with sample data
  Future<void> _initializeFirestoreWithSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing Firestore with sample data...';
      _hasError = false;
      _showJsonData = false;
    });

    try {
      await SampleDataLoader.initializeFirestoreWithSampleData();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Firestore initialized with sample data successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error initializing Firestore with sample data: $e';
        _hasError = true;
      });
    }
  }

  /// Generate sample appointments JSON
  void _generateSampleAppointmentsJson() {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating sample appointments JSON...';
      _hasError = false;
    });

    try {
      final json = JsonExportUtility.generateSampleAppointmentsJson();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Sample appointments JSON generated successfully!';
        _jsonData = json;
        _showJsonData = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error generating sample appointments JSON: $e';
        _hasError = true;
      });
    }
  }

  /// Generate sample doctors JSON
  void _generateSampleDoctorsJson() {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating sample doctors JSON...';
      _hasError = false;
    });

    try {
      final json = JsonExportUtility.generateSampleDoctorsJson();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Sample doctors JSON generated successfully!';
        _jsonData = json;
        _showJsonData = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error generating sample doctors JSON: $e';
        _hasError = true;
      });
    }
  }

  /// Generate sample patients JSON
  void _generateSamplePatientsJson() {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating sample patients JSON...';
      _hasError = false;
    });

    try {
      final json = JsonExportUtility.generateSamplePatientsJson();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Sample patients JSON generated successfully!';
        _jsonData = json;
        _showJsonData = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error generating sample patients JSON: $e';
        _hasError = true;
      });
    }
  }

  /// Copy JSON data to clipboard
  void _copyJsonToClipboard() {
    Clipboard.setData(ClipboardData(text: _jsonData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sample Data Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use this screen to load sample data into Firestore for testing purposes or generate JSON data for manual import.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            
            // Load data section
            const Text(
              'Load Data to Firestore',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Load Sample Appointments',
              description: 'Load sample appointments into Firestore.',
              icon: Icons.calendar_today,
              onPressed: _isLoading ? null : _loadSampleAppointments,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Initialize Firestore with Sample Data',
              description: 'Initialize Firestore with sample data for all collections.',
              icon: Icons.storage,
              onPressed: _isLoading ? null : _initializeFirestoreWithSampleData,
            ),
            
            const SizedBox(height: 32),
            
            // Generate JSON section
            const Text(
              'Generate JSON Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Generate Appointments JSON',
              description: 'Generate sample appointments data in JSON format.',
              icon: Icons.calendar_today,
              onPressed: _isLoading ? null : _generateSampleAppointmentsJson,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Generate Doctors JSON',
              description: 'Generate sample doctors data in JSON format.',
              icon: Icons.medical_services,
              onPressed: _isLoading ? null : _generateSampleDoctorsJson,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Generate Patients JSON',
              description: 'Generate sample patients data in JSON format.',
              icon: Icons.person,
              onPressed: _isLoading ? null : _generateSamplePatientsJson,
            ),
            
            const SizedBox(height: 32),
            
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_statusMessage.isNotEmpty && !_showJsonData)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hasError ? Colors.red[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _hasError ? Colors.red[900] : Colors.green[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            if (_showJsonData) Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _copyJsonToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy to Clipboard'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _jsonData,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build an action card
  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
} 
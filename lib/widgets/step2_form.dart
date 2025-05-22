import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For JSON encoding

// Step 2 Form for personal details
class Step2Form extends StatefulWidget {
  // New: Callback to notify parent to advance step and pass data
  final Function(Map<String, dynamic> formData, int? customerId) onStepCompleted;

  const Step2Form({
    super.key,
    required this.onStepCompleted, // Make the callback required
  });

  @override
  State<Step2Form> createState() => _Step2FormState();
}

class _Step2FormState extends State<Step2Form> {
  // Internal GlobalKey for this form's validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _iqamaController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State variable for marital status dropdown
  String? _selectedMaritalStatus;
  final List<String> _maritalStatuses = [
    'Single',
    'Married'
  ];

  // State variable to track if the form is currently valid
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers and the dropdown to trigger validity checks
    _nameController.addListener(_updateFormValidity);
    _lastNameController.addListener(_updateFormValidity);
    _nationalityController.addListener(_updateFormValidity);
    _nationalIdController.addListener(_updateFormValidity);
    _iqamaController.addListener(_updateFormValidity);
    _birthdateController.addListener(_updateFormValidity);
    _emailController.addListener(_updateFormValidity);
    _phoneNumberController.addListener(_updateFormValidity);
    _addressController.addListener(_updateFormValidity);

    // Perform an initial validation check after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormValidity();
    });
  }

  // Helper method to update the _isFormValid state
  void _updateFormValidity() {
    // Calling validate() here will trigger validators and update error messages.
    // We then update our internal _isFormValid state.
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers to free up resources
    _nameController.removeListener(_updateFormValidity);
    _lastNameController.removeListener(_updateFormValidity);
    _nationalityController.removeListener(_updateFormValidity);
    _nationalIdController.removeListener(_updateFormValidity);
    _iqamaController.removeListener(_updateFormValidity);
    _birthdateController.removeListener(_updateFormValidity);
    _emailController.removeListener(_updateFormValidity);
    _phoneNumberController.removeListener(_updateFormValidity);
    _addressController.removeListener(_updateFormValidity);

    _nameController.dispose();
    _lastNameController.dispose();
    _nationalityController.dispose();
    _nationalIdController.dispose();
    _iqamaController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Function to show a date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Set initial date to today
      firstDate: DateTime(1900), // Allow selection from 1900
      lastDate: DateTime.now(), // Don't allow future dates
    );
    if (picked != null) {
      setState(() {
        // Format the selected date and update the text field
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _updateFormValidity(); // Re-validate and update button state after date selection
    }
  }

  // Helper method to show a SnackBar message
  void _showSnackBar(String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Method to handle "Next" button press (when form is valid)
  void _handleNext() async {
    // This method will only be called if _isFormValid is true
    print('--- Step 2 Form is Valid! ---');

    // Collect data from controllers
    final Map<String, dynamic> formData = {
      'name': _nameController.text,
      'lastName': _lastNameController.text,
      'nationality': _nationalityController.text,
      'nationalId': _nationalIdController.text,
      'iqama': _iqamaController.text,
      'birthdate': _birthdateController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneNumberController.text,
      'address': _addressController.text,
      'maritalStatus': _selectedMaritalStatus ?? '', // Use empty string if not selected
    };

    print('Sending data: $formData');

    try {
      final response = await http.post(
        // Changed localhost to 10.0.2.2 for Android emulator access to host machine
        Uri.parse('http://10.0.2.2:4000/api/customer/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(formData), // Encode the map to a JSON string
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Request successful
        print('Raw response from server: ${response.body}');

        try {
          final Map<String, dynamic> responseJson = jsonDecode(response.body);
          final String? message = responseJson['message'];

          if (message == "Customer created successfully") {
            print('SUCCESS: Customer created successfully!');
            final int? customerId = responseJson['customer']?['id'];
            if (customerId != null) {
              print('Extracted Customer ID: $customerId');
              // Call the onStepCompleted callback to pass data and customerId to MyHomePage
              widget.onStepCompleted(formData, customerId);
            } else {
              print('WARNING: Customer ID not found in successful response.');
              _showSnackBar('Customer created, but ID not found.', color: Colors.orange);
              // Still call onStepCompleted, but with null customerId
              widget.onStepCompleted(formData, null);
            }
            _showSnackBar('Customer created successfully!', color: Colors.green);
          } else if (message == "Customer already exists") {
            print('INFO: Customer already exists. Message from server: $message');
            _showSnackBar('Customer already exists!', color: Colors.orange);
            // Do not advance step if customer already exists, user needs to correct
          }
          else {
            // Server responded with 200/201 but the message indicates an issue
            print('ERROR: Server responded with success status, but message indicates an issue: $message');
            _showSnackBar('Server response issue: $message', color: Colors.red);
          }
        } catch (e) {
          print('ERROR: Failed to parse server response as JSON: $e');
          print('Response body that caused parsing error: ${response.body}');
          _showSnackBar('Failed to parse server response.', color: Colors.red);
        }
      } else {
        // Request failed with a non-200/201 status code
        print('ERROR: Failed to send data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showSnackBar('Request failed: Status ${response.statusCode}', color: Colors.red);
      }
    } catch (e) {
      // Handle network errors (e.g., server unreachable, connection refused)
      print('ERROR: Network error sending request: $e');
      _showSnackBar('Network error. Please check your connection.', color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form( // Wrap the form content with a Form widget
      key: _formKey, // Assign the internal GlobalKey to the Form
      autovalidateMode: AutovalidateMode.onUserInteraction, // Validate on user interaction
      child: SingleChildScrollView( // Allows scrolling if content overflows
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Step 2: Personal Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Name Field (Required)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *', // Indicate required field
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Last Name Field (Required)
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Last Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Nationality Field (Required)
            TextFormField(
              controller: _nationalityController,
              decoration: const InputDecoration(
                labelText: 'Nationality *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nationality is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // National ID Field (One of National ID or Iqama is required)
            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(
                labelText: 'National ID *', // Indicate one of them is required
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                // Validate if either National ID or Iqama is filled
                if (_nationalIdController.text.isEmpty && _iqamaController.text.isEmpty) {
                  return 'Either National ID or Iqama is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Iqama Field (One of National ID or Iqama is required)
            TextFormField(
              controller: _iqamaController,
              decoration: const InputDecoration(
                labelText: 'Iqama (if applicable) *', // Indicate one of them is required
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                // This validator will also check the combined condition
                if (_nationalIdController.text.isEmpty && _iqamaController.text.isEmpty) {
                  return 'Either National ID or Iqama is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Birthdate Field with Date Picker (Required)
            TextFormField(
              controller: _birthdateController,
              readOnly: true, // Make the field read-only
              onTap: () => _selectDate(context), // Open date picker on tap
              decoration: const InputDecoration(
                labelText: 'Birthdate (YYYY-MM-DD) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down), // Indicate it's selectable
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Birthdate is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Email Field (Required)
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                // Basic email format validation
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Phone Number Field (Required)
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Address Field (Required)
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.streetAddress,
              maxLines: 3, // Allow multiple lines for address
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Marital Status Dropdown (Required)
            DropdownButtonFormField<String>(
              value: _selectedMaritalStatus,
              decoration: const InputDecoration(
                labelText: 'Marital Status *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.favorite),
              ),
              hint: const Text('Select Marital Status'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMaritalStatus = newValue;
                });
                _updateFormValidity(); // Re-validate and update button state after selection
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Marital Status is required';
                }
                return null;
              },
              items: _maritalStatuses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // "Next" button for this form
            ElevatedButton(
              onPressed: _isFormValid ? _handleNext : null, // Enabled only if form is valid
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}


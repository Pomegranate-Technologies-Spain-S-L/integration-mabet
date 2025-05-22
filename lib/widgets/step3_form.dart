import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For JSON encoding

// A simple model for an item in the list (still useful for data structure)
class Item {
  String itemCategory;
  String itemDescription;
  String value; // Storing as String to handle potential non-numeric input initially

  Item({
    required this.itemCategory,
    required this.itemDescription,
    required this.value,
  });

  // Method to convert Item object to JSON format for submission
  Map<String, dynamic> toJson() {
    return {
      'item_category': itemCategory,
      'item_description': itemDescription,
      'value': value,
    };
  }
}

// ItemInputRow widget is no longer needed as we will have a single item directly in Step3Form

class Step3Form extends StatefulWidget {
  // New: Parameters passed from previous steps (e.g., from MyHomePage)
  final int? insuranceId;    // From Step1Form
  final int? customerId;     // From Step2Form
  // Removed: Callback function to notify parent to advance step and pass data
  // final Function(Map<String, dynamic> formData, int? dataRequirementsId) onStepCompleted;


  const Step3Form({
    super.key,
    required this.insuranceId,   // Make it required
    required this.customerId,    // Make it required
    // Removed: required this.onStepCompleted,
  });

  @override
  State<Step3Form> createState() => _Step3FormState();
}

class _Step3FormState extends State<Step3Form> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Policy Holder Details fields
  String? _selectedMaritalStatus;
  final List<String> _maritalStatuses = ['Married', 'Single'];
  bool _hasPreviousClaims = false;
  bool _previousProposalRejected = false;
  final TextEditingController _policyStartDateController = TextEditingController();

  // Address Details fields
  bool _differentLocation = false; // Corresponds to "Yes" or "No"
  final TextEditingController _buildingNumberController = TextEditingController();
  final TextEditingController _additionalNumberController = TextEditingController(); // This is optional
  final TextEditingController _landmarksController = TextEditingController(); // Required

  // Building Details fields
  String? _selectedBuildingType;
  final List<String> _buildingTypes = ['Apartment', 'Townhouse', 'Villa'];
  final TextEditingController _floorNumberController = TextEditingController();
  bool _hasBasement = false;
  final TextEditingController _numberOfFloorsController = TextEditingController();
  final TextEditingController _propertyAreaController = TextEditingController();

  // Policy Details fields
  bool _nonConcrete = false;
  bool _isOwner = false; // Corresponds to "Are you the owner?"
  bool _useToBusiness = false; // New: use_to_business boolean
  bool _hasCCTV = false; // Corresponds to "Is there 24/7 CCTV in place?"
  bool _antiTheftAlarm = false; // Corresponds to "Is there any anti-theft alarm?"

  // Single Item fields (replacing the List<Item>)
  String? _selectedItemCategory;
  final List<String> _itemCategories = [
    'Electronics',
    'Jewelry',
    'Outdoor Content',
    'Fine Arts',
    'Furniture',
    'Miscellaneous',
  ];
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _itemValueController = TextEditingController();


  // State variable to track if the form is currently valid (for the button)
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update form validity
    _policyStartDateController.addListener(_updateFormValidity);
    _buildingNumberController.addListener(_updateFormValidity);
    _additionalNumberController.addListener(_updateFormValidity);
    _landmarksController.addListener(_updateFormValidity);

    // Listeners for Building Details
    _floorNumberController.addListener(_updateFormValidity);
    _numberOfFloorsController.addListener(_updateFormValidity);
    _propertyAreaController.addListener(_updateFormValidity);

    // Listeners for single Item fields
    _itemDescriptionController.addListener(_updateFormValidity);
    _itemValueController.addListener(_updateFormValidity);

    // No specific listeners needed for boolean SwitchListTiles, as onChanged handles setState and _updateFormValidity

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
      // Manually check dropdowns and switches as their changes don't automatically trigger TextFormField validators
      if (_selectedMaritalStatus == null || _selectedBuildingType == null || _selectedItemCategory == null) {
        _isFormValid = false;
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controllers to free up resources
    _policyStartDateController.removeListener(_updateFormValidity);
    _policyStartDateController.dispose();
    _buildingNumberController.removeListener(_updateFormValidity);
    _buildingNumberController.dispose();
    _additionalNumberController.removeListener(_updateFormValidity);
    _additionalNumberController.dispose();
    _landmarksController.removeListener(_updateFormValidity);
    _landmarksController.dispose();

    // Disposals for Building Details
    _floorNumberController.removeListener(_updateFormValidity);
    _floorNumberController.dispose();
    _numberOfFloorsController.removeListener(_updateFormValidity);
    _numberOfFloorsController.dispose();
    _propertyAreaController.removeListener(_updateFormValidity);
    _propertyAreaController.dispose();

    // Disposals for single Item fields
    _itemDescriptionController.removeListener(_updateFormValidity);
    _itemDescriptionController.dispose();
    _itemValueController.removeListener(_updateFormValidity);
    _itemValueController.dispose();

    super.dispose();
  }

  // Function to show a date picker for Policy Start Date
  Future<void> _selectPolicyStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Set initial date to today
      firstDate: DateTime(2000), // Allow selection from a reasonable past date
      lastDate: DateTime(2100), // Allow selection into the future
    );
    if (picked != null) {
      setState(() {
        // Format the selected date to YYYY-MM-DD and update the text field
        _policyStartDateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all required fields correctly.', color: Colors.red);
      return;
    }
    _updateFormValidity(); // Final check before submission

    if (!_isFormValid) {
      _showSnackBar('Please fill all required fields correctly to proceed.', color: Colors.red);
      return;
    }

    print('--- Step 3 Form is Valid! ---');

    // Collect data from all form fields for the first request
    final Map<String, dynamic> dataRequirementsPayload = {
      'marital_status': _selectedMaritalStatus ?? '',
      'previous_claims': _hasPreviousClaims, // Corrected key from previous_clams
      'previous_rejected': _previousProposalRejected,
      'policy_start_date': _policyStartDateController.text,
      'insurance_id': 1,
      'addressDetails': {
        'different_location': _differentLocation ? 'Yes' : 'No', // Changed to "Yes" or "No" string
        'building_number': _buildingNumberController.text,
        'additional_number': _additionalNumberController.text,
        'landmarks': _landmarksController.text,
      },
      'buildingDetails': { // Moved to top-level as per desired JSON structure
        'building_type': _selectedBuildingType ?? '',
        'floor_number': _floorNumberController.text,
        'basements': _hasBasement, // Corrected key from basement
        'number_of_floors': _numberOfFloorsController.text,
        'property_area': _propertyAreaController.text,
      },
      'policyDetails': {
        'non_concrete': _nonConcrete,
        'owner': _isOwner,
        'use_to_business': _useToBusiness,
        'has_cctv': _hasCCTV,
        'anti_theft_alarm': _antiTheftAlarm,
      },
      'itemlist': { // Single item, so directly an object
        'item_category': _selectedItemCategory ?? '',
        'item_description': _itemDescriptionController.text,
        'value': double.tryParse(_itemValueController.text) ?? 0.0, // Convert to double
      },
    };

    print('Sending data to dataRequirements/create: $dataRequirementsPayload');

    int? dataRequirementsId;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/dataRequirements/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(dataRequirementsPayload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Raw response from dataRequirements/create: ${response.body}');
        try {
          final Map<String, dynamic> responseJson = jsonDecode(response.body);
          final String? message = responseJson['message'];
          dataRequirementsId = responseJson['data']?['id']; // Corrected to data.id

          if (message == "Data requirements created successfully") {
            print('SUCCESS: Data requirements created successfully!');
            if (dataRequirementsId != null) {
              print('Extracted Data Requirements ID: $dataRequirementsId');
            } else {
              print('WARNING: Data Requirements ID not found in successful response.');
            }
            _showSnackBar('Data requirements submitted successfully!', color: Colors.green);

            // --- Conditional Proceed to the second request: createNewOffer ---
            if (widget.customerId != null && widget.insuranceId != null && dataRequirementsId != null) {
              final Map<String, dynamic> newOfferPayload = {
                'customer_id': widget.customerId,
                'data_requirements_id': dataRequirementsId,
                'product_id': widget.insuranceId, // Use the actual insuranceId
              };

              print('Sending data to newOffer/createNewOffer: $newOfferPayload');

              final offerResponse = await http.post(
                Uri.parse('http://10.0.2.2:4000/api/newOffer/createNewOffer'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(newOfferPayload),
              );

              if (offerResponse.statusCode == 200 || offerResponse.statusCode == 201) {
                print('Raw response from newOffer/createNewOffer: ${offerResponse.body}');
                try {
                  final Map<String, dynamic> offerResponseJson = jsonDecode(offerResponse.body);
                  final String? offerMessage = offerResponseJson['message'];

                  if (offerMessage == "New offer created successfully") {
                    print('SUCCESS: Offer created successfully!');
                    _showSnackBar('Offer created successfully!', color: Colors.green);
                  } else {
                    _showSnackBar('Offer creation issue: $offerMessage', color: Colors.red);
                    print('ERROR: Offer creation server responded with success status, but message indicates an issue: $offerMessage');
                  }
                } catch (e) {
                  _showSnackBar('Failed to parse offer server response.', color: Colors.red);
                  print('ERROR: Failed to parse offer server response as JSON: $e');
                }
              } else {
                _showSnackBar('Offer request failed: Status ${offerResponse.statusCode}', color: Colors.red);
                print('ERROR: Failed to send offer data. Status code: ${offerResponse.statusCode}');
                print('Offer Response body: ${offerResponse.body}');
              }
            } else {
              // Show message if customerId, insuranceId, or dataRequirementsId is missing for the second request
              _showSnackBar('Cannot create offer: Customer ID, Insurance ID, or Data Requirements ID is missing.', color: Colors.orange);
              print('INFO: Skipping offer creation because customerId (${widget.customerId}), insuranceId (${widget.insuranceId}), or dataRequirementsId ($dataRequirementsId) is null.');
            }
            // --- End of second request handling ---

          } else {
            _showSnackBar('Data requirements server response issue: $message', color: Colors.red);
            print('ERROR: Data requirements server responded with success status, but message indicates an issue: $message');
          }
        } catch (e) {
          _showSnackBar('Failed to parse data requirements server response.', color: Colors.red);
          print('ERROR: Failed to parse data requirements server response as JSON: $e');
        }
      } else {
        _showSnackBar('Data requirements request failed: Status ${response.statusCode}', color: Colors.red);
        print('ERROR: Failed to send data requirements data. Status code: ${response.statusCode}');
        print('Data requirements Response body: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Network error. Please check your connection.', color: Colors.red);
      print('ERROR: Network error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction, // Validate on user interaction
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Changed padding to all sides
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Step 3: Policy and Item Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Section 1: Policy Holder Details
            const Text(
              'Policy Holder Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1), // Visual separator
            const SizedBox(height: 16),

            // Marital Status Dropdown
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
                _updateFormValidity(); // Re-validate and update button state
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
            const SizedBox(height: 16),

            // Do you have any previous claims? (Boolean)
            SwitchListTile(
              title: const Text('Do you have any previous claims? *'),
              value: _hasPreviousClaims,
              onChanged: (bool value) {
                setState(() {
                  _hasPreviousClaims = value;
                });
                _updateFormValidity(); // Re-validate and update button state
              },
            ),
            const SizedBox(height: 16),

            // Any previous proposal was rejected? (Boolean)
            SwitchListTile(
              title: const Text('Any previous proposal was rejected? *'),
              value: _previousProposalRejected,
              onChanged: (bool value) {
                setState(() {
                  _previousProposalRejected = value;
                });
                _updateFormValidity(); // Re-validate and update button state
              },
            ),
            const SizedBox(height: 16),

            // Policy Start Date
            TextFormField(
              controller: _policyStartDateController,
              readOnly: true, // Make the field read-only
              onTap: () => _selectPolicyStartDate(context), // Open date picker on tap
              decoration: const InputDecoration(
                labelText: 'Policy Start Date (YYYY-MM-DD) *', // Updated label for clarity
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down), // Indicate it's selectable
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Policy start date is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20), // Spacing after section

            // Section 2: Address Details
            const Text(
              'Address Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1), // Visual separator
            const SizedBox(height: 16),

            // Different Location (Boolean) - Always visible
            SwitchListTile(
              title: const Text('Is this a different location? (Yes/No) *'),
              value: _differentLocation,
              onChanged: (bool value) {
                setState(() {
                  _differentLocation = value;
                  // Clear fields if not a different location
                  // This logic is still here for data consistency, but fields remain visible
                  if (!value) {
                    _buildingNumberController.clear();
                    _additionalNumberController.clear();
                    _landmarksController.clear();
                  }
                });
                _updateFormValidity(); // Re-validate and update button state
              },
            ),
            const SizedBox(height: 16),

            // Building Number (Always visible, required)
            TextFormField(
              controller: _buildingNumberController,
              decoration: const InputDecoration(
                labelText: 'Building Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Building Number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Landmarks (Always visible, required)
            TextFormField(
              controller: _landmarksController,
              decoration: const InputDecoration(
                labelText: 'Landmarks *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Landmarks is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Additional Number (Always visible, Optional)
            TextFormField(
              controller: _additionalNumberController,
              decoration: const InputDecoration(
                labelText: 'Additional Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
              ),
              keyboardType: TextInputType.text,
              maxLines: 2, // Allow multiple lines for descriptive text
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 20), // Spacing after section

            // Section 3: Building Details
            const Text(
              'Building Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1), // Visual separator
            const SizedBox(height: 16),

            // Building Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBuildingType,
              decoration: const InputDecoration(
                labelText: 'Building Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
              ),
              hint: const Text('Select Building Type'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBuildingType = newValue;
                });
                _updateFormValidity(); // Re-validate and update button state
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Building Type is required';
                }
                return null;
              },
              items: _buildingTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Floor Number
            TextFormField(
              controller: _floorNumberController,
              decoration: const InputDecoration(
                labelText: 'Floor Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.stairs),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Floor Number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Basement (Boolean)
            SwitchListTile(
              title: const Text('Has Basement? *'),
              value: _hasBasement,
              onChanged: (bool value) {
                setState(() {
                  _hasBasement = value;
                });
                _updateFormValidity(); // Re-validate and update button state
              },
            ),
            const SizedBox(height: 16),

            // Number of Floors
            TextFormField(
              controller: _numberOfFloorsController,
              decoration: const InputDecoration(
                labelText: 'Number of Floors *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.layers),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Number of Floors is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Property Area
            TextFormField(
              controller: _propertyAreaController,
              decoration: const InputDecoration(
                labelText: 'Property Area (e.g., 120 sqm) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.area_chart),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Property Area is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20), // Spacing after section

            // Section 4: Policy Details
            const Text(
              'Policy Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1), // Visual separator
            const SizedBox(height: 16),

            // Non-Concrete (Boolean)
            SwitchListTile(
              title: const Text('Is it non-concrete? *'),
              value: _nonConcrete,
              onChanged: (bool value) {
                setState(() {
                  _nonConcrete = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 16),

            // Are you the owner? (Boolean)
            SwitchListTile(
              title: const Text('Are you the owner? *'),
              value: _isOwner,
              onChanged: (bool value) {
                setState(() {
                  _isOwner = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 16),

            // Is it used for business? (Boolean)
            SwitchListTile(
              title: const Text('Is it used for business? *'), // New: use_to_business
              value: _useToBusiness,
              onChanged: (bool value) {
                setState(() {
                  _useToBusiness = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 16),

            // Is there 24/7 CCTV in place? (Boolean)
            SwitchListTile(
              title: const Text('Is there 24/7 CCTV in place? *'),
              value: _hasCCTV,
              onChanged: (bool value) {
                setState(() {
                  _hasCCTV = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 16),

            // Is there any anti-theft alarm? (Boolean)
            SwitchListTile(
              title: const Text('Is there any anti-theft alarm? *'),
              value: _antiTheftAlarm,
              onChanged: (bool value) {
                setState(() {
                  _antiTheftAlarm = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 20), // Spacing after section


            // Section 5: Items List
            const Text(
              'Items List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1), // Visual separator
            const SizedBox(height: 16),

            // Item Category Dropdown (single item)
            DropdownButtonFormField<String>(
              value: _selectedItemCategory,
              decoration: const InputDecoration(
                labelText: 'Item Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              hint: const Text('Select Category'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItemCategory = newValue;
                });
                _updateFormValidity();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Item Category is required';
                }
                return null;
              },
              items: _itemCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Item Description (single item)
            TextFormField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Item Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Item Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Value (in SAR) (single item)
            TextFormField(
              controller: _itemValueController,
              decoration: const InputDecoration(
                labelText: 'Value (in SAR) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Value is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20), // Spacing after section

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

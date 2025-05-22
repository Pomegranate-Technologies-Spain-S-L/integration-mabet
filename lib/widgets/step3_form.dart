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

class Step3Form extends StatefulWidget {
  final int? insuranceId;    // From Step1Form
  final int? customerId;     // From Step2Form
  final String? token;       // Token received from MyHomePage

  const Step3Form({
    super.key,
    required this.insuranceId,
    required this.customerId,
    this.token, // Receive the token here
  });

  @override
  State<Step3Form> createState() => _Step3FormState();
}

class _Step3FormState extends State<Step3Form> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Policy Holder Details fields
  bool _hasPreviousClaims = false;
  bool _previousProposalRejected = false;
  final TextEditingController _policyStartDateController = TextEditingController();

  // Address Details fields
  // Removed: bool _differentLocation = false;
  // Removed: final TextEditingController _buildingNumberController = TextEditingController();
  // Removed: final TextEditingController _additionalNumberController = TextEditingController();
  // Removed: final TextEditingController _landmarksController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // New: Single address field

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
  double? _offerPrice; // To store the price from the new offer
  bool _showPurchaseButton = false; // To control visibility of purchase button
  bool _calculationCompleted = false; // New: To hide calculate button after calculation

  @override
  void initState() {
    super.initState();
    // Add listeners to update form validity
    _policyStartDateController.addListener(_updateFormValidity);
    _addressController.addListener(_updateFormValidity); // New listener for address

    // Listeners for Building Details
    _floorNumberController.addListener(_updateFormValidity);
    _numberOfFloorsController.addListener(_updateFormValidity);
    _propertyAreaController.addListener(_updateFormValidity);

    // Listeners for single Item fields (now required again)
    _itemDescriptionController.addListener(_updateFormValidity);
    _itemValueController.addListener(_updateFormValidity);

    // Perform an initial validation check after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormValidity();
    });
  }

  // Helper method to update the _isFormValid state
  void _updateFormValidity() {
    setState(() {
      // Validate only required fields. Item category is now optional.
      _isFormValid = _formKey.currentState?.validate() ?? false;
      if (_selectedBuildingType == null || _selectedItemCategory == null) { // Item category is now required again
        _isFormValid = false;
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controllers to free up resources
    _policyStartDateController.removeListener(_updateFormValidity);
    _policyStartDateController.dispose();
    _addressController.removeListener(_updateFormValidity); // Dispose new address controller
    _addressController.dispose();

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
      _updateFormValidity();
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

  // Method to handle "Calculate" button press (when form is valid)
  void _handleCalculate() async {
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

    // Prepare Building Details based on selected type
    Map<String, dynamic> buildingDetailsPayload = {
      'building_type': _selectedBuildingType ?? '',
      'floor_number': '',
      'basements': false,
      'number_of_floors': '',
      'property_area': '',
    };

    if (_selectedBuildingType == 'Apartment') {
      buildingDetailsPayload['floor_number'] = _floorNumberController.text;
      buildingDetailsPayload['property_area'] = _propertyAreaController.text;
    } else if (_selectedBuildingType == 'Townhouse' || _selectedBuildingType == 'Villa') {
      buildingDetailsPayload['basements'] = _hasBasement;
      buildingDetailsPayload['number_of_floors'] = _numberOfFloorsController.text;
      buildingDetailsPayload['property_area'] = _propertyAreaController.text;
    }

    // Collect data from all form fields for the first request
    final Map<String, dynamic> dataRequirementsPayload = {
      'marital_status': "", // Always send empty string as requested
      'previous_claims': _hasPreviousClaims,
      'previous_rejected': _previousProposalRejected,
      'policy_start_date': _policyStartDateController.text,
      'insurance_id': 1, // Static 1 as requested
      'addressDetails': {
        'address': _addressController.text, // Single address field
      },
      'buildingDetails': buildingDetailsPayload, // Use the dynamically prepared payload
      'policyDetails': {
        'non_concrete': _nonConcrete,
        'owner': _isOwner,
        'use_to_business': _useToBusiness,
        'has_cctv': _hasCCTV,
        'anti_theft_alarm': _antiTheftAlarm,
      },
      'itemlist': {
        'item_category': _selectedItemCategory ?? '',
        'item_description': _itemDescriptionController.text,
        'value': double.tryParse(_itemValueController.text) ?? 0.0,
      },
    };

    print('Sending data to dataRequirements/create: $dataRequirementsPayload');

    int? dataRequirementsId;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/api/dataRequirements/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (widget.token != null) 'Authorization': 'Bearer ${widget.token}', // Add token
        },
        body: jsonEncode(dataRequirementsPayload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Raw response from dataRequirements/create: ${response.body}');
        try {
          final Map<String, dynamic> responseJson = jsonDecode(response.body);
          final String? message = responseJson['message'];
          dataRequirementsId = responseJson['data']?['id'];

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
                'product_id': widget.insuranceId,
              };

              print('Sending data to newOffer/createNewOffer: $newOfferPayload');

              final offerResponse = await http.post(
                Uri.parse('http://localhost:4000/api/newOffer/createNewOffer'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  if (widget.token != null) 'Authorization': 'Bearer ${widget.token}', // Add token
                },
                body: jsonEncode(newOfferPayload),
              );

              if (offerResponse.statusCode == 200 || offerResponse.statusCode == 201) {
                print('Raw response from newOffer/createNewOffer: ${offerResponse.body}');
                try {
                  final Map<String, dynamic> offerResponseJson = jsonDecode(offerResponse.body);
                  final String? offerMessage = offerResponseJson['message'];
                  // Corrected price extraction: responseJson['data']?['offer_price']
                  final double? price = offerResponseJson['data']?['offer_price']?.toDouble();

                  if (offerMessage == "New offer created successfully") {
                    print('SUCCESS: Offer created successfully!');
                    _showSnackBar('Offer created successfully!', color: Colors.green);
                    setState(() {
                      _offerPrice = price; // Store the price
                      _showPurchaseButton = true; // Show the purchase button
                      _calculationCompleted = true; // Hide the calculate button
                    });
                  } else {
                    _showSnackBar('Offer creation issue: $offerMessage', color: Colors.red);
                    print('ERROR: Offer creation server responded with success status, but message indicates an issue: $offerMessage');
                    setState(() {
                      _offerPrice = null; // Clear price on error
                      _showPurchaseButton = false;
                      _calculationCompleted = false; // Keep calculate button visible on error
                    });
                  }
                } catch (e) {
                  _showSnackBar('Failed to parse offer server response.', color: Colors.red);
                  print('ERROR: Failed to parse offer server response as JSON: $e');
                  setState(() {
                    _offerPrice = null;
                    _showPurchaseButton = false;
                    _calculationCompleted = false;
                  });
                }
              } else {
                _showSnackBar('Offer request failed: Status ${offerResponse.statusCode}', color: Colors.red);
                print('ERROR: Failed to send offer data. Status code: ${offerResponse.statusCode}');
                print('Offer Response body: ${offerResponse.body}');
                setState(() {
                  _offerPrice = null;
                  _showPurchaseButton = false;
                  _calculationCompleted = false;
                });
              }
            } else {
              _showSnackBar('Cannot create offer: Customer ID, Insurance ID, or Data Requirements ID is missing.', color: Colors.orange);
              print('INFO: Skipping offer creation because customerId (${widget.customerId}), insuranceId (${widget.insuranceId}), or dataRequirementsId ($dataRequirementsId) is null.');
              setState(() {
                _offerPrice = null;
                _showPurchaseButton = false;
                _calculationCompleted = false;
              });
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
              'Policy and Item Details', // Removed "Step 3:"
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

            // Single Address Field
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.streetAddress,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
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
                  // Clear relevant fields when building type changes
                  _floorNumberController.clear();
                  _hasBasement = false;
                  _numberOfFloorsController.clear();
                  _propertyAreaController.clear();
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

            // Dynamic Building Detail Fields based on _selectedBuildingType
            if (_selectedBuildingType == 'Apartment') ...[
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
            ] else if (_selectedBuildingType == 'Townhouse' || _selectedBuildingType == 'Villa') ...[
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
              TextFormField(
                controller: _numberOfFloorsController,
                decoration: const InputDecoration(
                  labelText: 'How many floors does the building have? *', // Changed label
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
              TextFormField(
                controller: _propertyAreaController,
                decoration: const InputDecoration(
                  labelText: 'What is the property area (e.g., 120 sqm)? *', // Changed label
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
            ],
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

            // Item Category Dropdown (now required again)
            DropdownButtonFormField<String>(
              value: _selectedItemCategory,
              decoration: const InputDecoration(
                labelText: 'Item Category *', // Required again
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              hint: const Text('Select Category'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItemCategory = newValue;
                });
                _updateFormValidity(); // Re-validate
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

            // Item Description (now required again)
            TextFormField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Item Description *', // Required again
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

            // Value (in SAR) (now required again)
            TextFormField(
              controller: _itemValueController,
              decoration: const InputDecoration(
                labelText: 'Value (in SAR) *', // Required again
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

            // Display Offer Price if available
            if (_offerPrice != null) ...[
              const SizedBox(height: 20),
              Text(
                'Calculated Offer Price: ${_offerPrice!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            // "Calculate" button for this form (hidden after calculation)
            if (!_calculationCompleted)
              ElevatedButton(
                onPressed: _isFormValid ? _handleCalculate : null, // Enabled only if form is valid
                child: const Text('Calculate'), // Changed button text
              ),
            const SizedBox(height: 10),

            // Purchase button (conditionally visible)
            if (_showPurchaseButton)
              ElevatedButton(
                onPressed: () {
                  // Implement purchase logic here
                  _showSnackBar('Purchased!', color: Colors.blue);
                  print('Purchase button pressed!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // A distinct color for purchase
                  foregroundColor: Colors.white,
                ),
                child: const Text('Purchase'),
              ),
          ],
        ),
      ),
    );
  }
}

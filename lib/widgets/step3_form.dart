import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Item {
  String itemCategory;
  String itemDescription;
  String value;

  Item({
    required this.itemCategory,
    required this.itemDescription,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_category': itemCategory,
      'item_description': itemDescription,
      'value': value,
    };
  }
}

class Step3Form extends StatefulWidget {
  final int? productId;
  final ValueChanged<Map<String, dynamic>> onOfferCalculated; // Callback to pass data after calculation
  final VoidCallback onPurchaseCompleted; // New callback for purchase button click

  const Step3Form({
    super.key,
    required this.productId,
    required this.onOfferCalculated,
    required this.onPurchaseCompleted, // Make the new callback required
  });

  @override
  State<Step3Form> createState() => _Step3FormState();
}

class _Step3FormState extends State<Step3Form> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _internalCustomerId;
  String? _internalToken;

  String? _selectedMaritalStatus;
  final List<String> _maritalStatuses = ['Married', 'Single'];
  bool _hasPreviousClaims = false;
  bool _previousProposalRejected = false;
  final TextEditingController _policyStartDateController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  String? _selectedBuildingType;
  final List<String> _buildingTypes = ['Apartment', 'Townhouse', 'Villa'];
  final TextEditingController _floorNumberController = TextEditingController();
  bool _hasBasement = false;
  final TextEditingController _numberOfFloorsController = TextEditingController();
  final TextEditingController _propertyAreaController = TextEditingController();

  bool _nonConcrete = false;
  bool _isOwner = false;
  bool _useToBusiness = false;
  bool _hasCCTV = false;
  bool _antiTheftAlarm = false;

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

  bool _isFormValid = false;
  double? _offerPrice;
  bool _showPurchaseButton = false;
  bool _calculationCompleted = false;

  @override
  void initState() {
    super.initState();
    _addressController.text = 'Chalco, Edo Mex';

    _policyStartDateController.addListener(_updateFormValidity);
    _addressController.addListener(_updateFormValidity);

    _floorNumberController.addListener(_updateFormValidity);
    _numberOfFloorsController.addListener(_updateFormValidity);
    _propertyAreaController.addListener(_updateFormValidity);

    _itemDescriptionController.addListener(_updateFormValidity);
    _itemValueController.addListener(_updateFormValidity);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormValidity();
    });
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
      if (_selectedBuildingType == null || _selectedMaritalStatus == null) {
        _isFormValid = false;
      }
    });
  }

  @override
  void dispose() {
    _policyStartDateController.removeListener(_updateFormValidity);
    _policyStartDateController.dispose();
    _addressController.removeListener(_updateFormValidity);
    _addressController.dispose();

    _floorNumberController.removeListener(_updateFormValidity);
    _floorNumberController.dispose();
    _numberOfFloorsController.removeListener(_updateFormValidity);
    _numberOfFloorsController.dispose();
    _propertyAreaController.removeListener(_updateFormValidity);
    _propertyAreaController.dispose();

    _itemDescriptionController.removeListener(_updateFormValidity);
    _itemDescriptionController.dispose();
    _itemValueController.removeListener(_updateFormValidity);
    _itemValueController.dispose();

    super.dispose();
  }

  Future<void> _selectPolicyStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _policyStartDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _updateFormValidity();
    }
  }

  void _showSnackBar(String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleCalculate() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all required fields correctly.', color: Colors.red);
      return;
    }
    _updateFormValidity();

    if (!_isFormValid) {
      _showSnackBar('Please fill all required fields correctly to proceed.', color: Colors.red);
      return;
    }

    print('--- Step 3 Form is Valid! ---');

    // 1. Call customer/create API
    final Map<String, dynamic> customerPayload = {
      'name': "Oscar",
      'lastName': "Antonio",
      'nationality': "Mexican",
      'nationalId': "ROCO010924HMCDRSA0",
      'iqama': "sd13r",
      'birthdate': "2001-09-24",
      'email': "test@test",
      'phoneNumber': "5530234861",
      'address': "Chalco Edo Mex",
      'maritalStatus': _selectedMaritalStatus ?? '',
    };

    print('Sending data to customer/create: $customerPayload');

    try {
      final customerResponse = await http.post(
        Uri.parse('https://api-test.rommaana.com/api/customer/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(customerPayload),
      );

      if (customerResponse.statusCode == 200 || customerResponse.statusCode == 201) {
        print('Raw response from customer/create: ${customerResponse.body}');
        try {
          final Map<String, dynamic> customerResponseJson = jsonDecode(customerResponse.body);
          final String? customerMessage = customerResponseJson['message'];

          if (customerMessage == "Customer created successfully" || customerMessage == "Customer already exists") {
            print('SUCCESS: Customer operation successful!');
            _internalCustomerId = customerResponseJson['customer']?['id'];
            _internalToken = customerResponseJson['token'];

            if (_internalCustomerId != null) {
              print('Extracted Customer ID: $_internalCustomerId');
            } else {
              print('WARNING: Customer ID not found in successful customer response.');
            }
            if (_internalToken != null) {
              print('Extracted Token: $_internalToken');
            } else {
              print('WARNING: Token not found in successful customer response.');
            }
            _showSnackBar('Customer data processed successfully!', color: Colors.green);

            // Proceed to 2. Call dataRequirements/create API
            await _callDataRequirementsCreate(_internalCustomerId, _internalToken);

          } else {
            _showSnackBar('Customer API issue: $customerMessage', color: Colors.red);
            print('ERROR: Customer API responded with success status, but message indicates an issue: $customerMessage');
            _resetCalculationState();
          }
        } catch (e) {
          _showSnackBar('Failed to parse customer API response.', color: Colors.red);
          print('ERROR: Failed to parse customer API response as JSON: $e');
          _resetCalculationState();
        }
      } else {
        _showSnackBar('Customer API request failed: Status ${customerResponse.statusCode}', color: Colors.red);
        print('ERROR: Failed to send customer data. Status code: ${customerResponse.statusCode}');
        print('Customer Response body: ${customerResponse.body}');
        _resetCalculationState();
      }
    } catch (e) {
      _showSnackBar('Network error for customer API. Please check your connection.', color: Colors.red);
      print('ERROR: Network error sending customer request: $e');
      _resetCalculationState();
    }
  }

  Future<void> _callDataRequirementsCreate(int? customerId, String? token) async {
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

    final Map<String, dynamic> dataRequirementsPayload = {
      'marital_status': _selectedMaritalStatus ?? '',
      'previous_claims': _hasPreviousClaims,
      'previous_rejected': _previousProposalRejected,
      'policy_start_date': _policyStartDateController.text,
      'insurance_id': 1,
      'addressDetails': {
        'address': _addressController.text,
      },
      'buildingDetails': buildingDetailsPayload,
      'policyDetails': {
        'non_concrete': _nonConcrete,
        'owner': _isOwner,
        'use_to_business': _useToBusiness,
        'has_cctv': _hasCCTV,
        'anti_theft_alarm': _antiTheftAlarm,
      },
      'itemlist': {
        'item_category': _selectedItemCategory ?? "Jewelry",
        'item_description': _itemDescriptionController.text.isEmpty
            ? "Diamond necklace stored in home safe"
            : _itemDescriptionController.text,
        'value': double.tryParse(_itemValueController.text) ?? 8000.0,
      },
    };

    print('Sending data to dataRequirements/create: $dataRequirementsPayload');

    int? dataRequirementsId;

    try {
      final response = await http.post(
        Uri.parse('https://api-test.rommaana.com/api/dataRequirements/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
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

            // Proceed to 3. Call newOffer/createNewOffer
            if (customerId != null && widget.productId != null && dataRequirementsId != null) {
              final Map<String, dynamic> newOfferPayload = {
                'customer_id': customerId,
                'data_requirements_id': dataRequirementsId,
                'product_id': widget.productId,
              };

              print('Sending data to newOffer/createNewOffer: $newOfferPayload');

              final offerResponse = await http.post(
                Uri.parse('https://api-test.rommaana.com/api/newOffer/createNewOffer'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  if (token != null) 'Authorization': 'Bearer $token',
                },
                body: jsonEncode(newOfferPayload),
              );

              if (offerResponse.statusCode == 200 || offerResponse.statusCode == 201) {
                print('Raw response from newOffer/createNewOffer: ${offerResponse.body}');
                try {
                  final Map<String, dynamic> offerResponseJson = jsonDecode(offerResponse.body);
                  final String? offerMessage = offerResponseJson['message'];
                  final double? price = offerResponseJson['data']?['offer_price']?.toDouble();

                  if (offerMessage == "New offer created successfully") {
                    print('SUCCESS: Offer created successfully!');
                    _showSnackBar('Offer created successfully!', color: Colors.green);
                    setState(() {
                      _offerPrice = price;
                      _showPurchaseButton = true;
                      _calculationCompleted = true;
                    });
                    // Pass the full 'data' object to the parent
                    widget.onOfferCalculated(offerResponseJson['data']);
                  } else {
                    _showSnackBar('Offer creation issue: $offerMessage', color: Colors.red);
                    print('ERROR: Offer creation server responded with success status, but message indicates an issue: $offerMessage');
                    _resetCalculationState();
                  }
                } catch (e) {
                  _showSnackBar('Failed to parse offer server response.', color: Colors.red);
                  print('ERROR: Failed to parse offer server response as JSON: $e');
                  _resetCalculationState();
                }
              } else {
                _showSnackBar('Offer request failed: Status ${offerResponse.statusCode}', color: Colors.red);
                print('ERROR: Failed to send offer data. Status code: ${offerResponse.statusCode}');
                print('Offer Response body: ${offerResponse.body}');
                _resetCalculationState();
              }
            } else {
              _showSnackBar('Cannot create offer: Customer ID, Product ID, or Data Requirements ID is missing.', color: Colors.orange);
              print('INFO: Skipping offer creation because customerId ($customerId), productId (${widget.productId}), or dataRequirementsId ($dataRequirementsId) is null.');
              _resetCalculationState();
            }

          } else {
            _showSnackBar('Data requirements server response issue: $message', color: Colors.red);
            print('ERROR: Data requirements server responded with success status, but message indicates an issue: $message');
            _resetCalculationState();
          }
        } catch (e) {
          _showSnackBar('Failed to parse data requirements server response.', color: Colors.red);
          print('ERROR: Failed to parse data requirements server response as JSON: $e');
          _resetCalculationState();
        }
      } else {
        _showSnackBar('Data requirements request failed: Status ${response.statusCode}', color: Colors.red);
        print('ERROR: Failed to send data requirements data. Status code: ${response.statusCode}');
        print('Data requirements Response body: ${response.body}');
        _resetCalculationState();
      }
    } catch (e) {
      _showSnackBar('Network error. Please check your connection.', color: Colors.red);
      print('ERROR: Network error sending request: $e');
      _resetCalculationState();
    }
  }

  void _resetCalculationState() {
    setState(() {
      _offerPrice = null;
      _showPurchaseButton = false;
      _calculationCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Policy and Item Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            const Text(
              'Policy Holder Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 16),

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
                _updateFormValidity();
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

            SwitchListTile(
              title: const Text('Do you have any previous claims? *'),
              value: _hasPreviousClaims,
              onChanged: (bool value) {
                setState(() {
                  _hasPreviousClaims = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Any previous proposal was rejected? *'),
              value: _previousProposalRejected,
              onChanged: (bool value) {
                setState(() {
                  _previousProposalRejected = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _policyStartDateController,
              readOnly: true,
              onTap: () => _selectPolicyStartDate(context),
              decoration: const InputDecoration(
                labelText: 'Policy Start Date (YYYY-MM-DD) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Policy start date is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            const Text(
              'Address Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.streetAddress,
              maxLines: 3,
              enabled: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            const Text(
              'Building Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 16),

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
                  _floorNumberController.clear();
                  _hasBasement = false;
                  _numberOfFloorsController.clear();
                  _propertyAreaController.clear();
                });
                _updateFormValidity();
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
                  _updateFormValidity();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberOfFloorsController,
                decoration: const InputDecoration(
                  labelText: 'How many floors does the building have? *',
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
                  labelText: 'What is the property area (e.g., 120 sqm)? *',
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
            const SizedBox(height: 20),

            const Text(
              'Policy Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 16),

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

            SwitchListTile(
              title: const Text('Is it used for business? *'),
              value: _useToBusiness,
              onChanged: (bool value) {
                setState(() {
                  _useToBusiness = value;
                });
                _updateFormValidity();
              },
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items List',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '(Optional)',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedItemCategory,
              decoration: const InputDecoration(
                labelText: 'Item Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              hint: const Text('Select Category'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItemCategory = newValue;
                });
              },
              items: _itemCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Item Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _itemValueController,
              decoration: const InputDecoration(
                labelText: 'Value (in SAR)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            if (_offerPrice != null) ...[
              const SizedBox(height: 20),
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Your Estimated Price:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_offerPrice!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (!_calculationCompleted)
              ElevatedButton(
                onPressed: _isFormValid ? _handleCalculate : null,
                child: const Text('Calculate'),
              ),
            const SizedBox(height: 10),

            if (_showPurchaseButton)
              ElevatedButton(
                onPressed: () {
                  // Trigger the callback to navigate to the next screen
                  widget.onPurchaseCompleted();
                  _showSnackBar('Purchased!', color: Colors.blue);
                  print('Purchase button pressed!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
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

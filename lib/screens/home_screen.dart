import 'package:flutter/material.dart';
import 'package:rommaana_form/widgets/step1_form.dart';
import 'package:rommaana_form/widgets/step2_form.dart';
import 'package:rommaana_form/widgets/step3_form.dart'; // Import Step3Form

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentStep = 0; // State variable to track the current step
  int? _selectedProductId; // Stores the selected product ID (int) from Step1Form
  int? _customerId; // Stores the customer ID (int) received from Step2Form API response
  int? _dataRequirementsId; // Stores the data requirements ID (int) received from Step3Form API response

  // Data collected from forms (can be expanded into a dedicated data model later)
  Map<String, dynamic> _step2FormData = {}; // Stores all data from Step2Form
  Map<String, dynamic> _step3FormData = {}; // Stores all data from Step3Form

  @override
  void initState() {
    super.initState();
    // No need to initialize _steps here anymore, as it will be built dynamically
  }

  // Method to build the widget for the current step dynamically
  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return Step1Form(
          onCardSelected: (int? productId) {
            setState(() {
              _selectedProductId = productId;
              print('MyHomePage received selected product ID: $_selectedProductId');
            });
          },
          onStepCompleted: () {
            setState(() {
              _currentStep++;
              print('Advancing from Step 1 to Step 2...');
            });
          },
        );
      case 1:
        return Step2Form(
          onStepCompleted: (Map<String, dynamic> formData, int? customerId) {
            setState(() {
              _step2FormData = formData;
              _customerId = customerId;
              _currentStep++;
              print('MyHomePage received Step 2 data: $_step2FormData');
              print('MyHomePage received Customer ID: $_customerId');
              print('Advancing from Step 2 to Step 3...');
            });
          },
        );
      case 2:
      // Step 3: Policy Details and Item List Form
      // This is now built dynamically, ensuring _selectedProductId and _customerId are up-to-date
        return Step3Form(
          insuranceId: _selectedProductId, // Pass selectedProductId from Step1
          customerId: _customerId, // Pass customerId from Step2
          // We will add onStepCompleted callback for Step3Form later when its logic is ready
        );
      default:
        return const Center(child: Text('Form Completed!')); // Or a final summary screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          // Display the current step's widget dynamically.
          Expanded(
            child: _buildCurrentStepWidget(), // Call the helper method here
          ),
          // Global navigation buttons are removed. Each step manages its own "Next" button.
        ],
      ),
    );
  }
}

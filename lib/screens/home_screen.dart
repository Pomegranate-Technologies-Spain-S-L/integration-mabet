import 'package:flutter/material.dart';
import 'package:rommaana_form/widgets/step1_form.dart';
import 'package:rommaana_form/widgets/step2_form.dart';
import 'package:rommaana_form/widgets/step3_form.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentStep = 0;
  int? _selectedProductId;
  int? _customerId;
  String? _token;

  Map<String, dynamic> _step2FormData = {};
  Map<String, dynamic> _step3FormData = {};

  @override
  void initState() {
    super.initState();
  }

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
          onTokenReceived: (String? receivedToken) { // This is how Step2Form passes the token UP to MyHomePage
            setState(() {
              _token = receivedToken;
              print('MyHomePage received token: $_token');
            });
          },
        );
      case 2:
        return Step3Form(
          insuranceId: _selectedProductId,
          customerId: _customerId,
          token: _token, // Pass the token to Step3Form
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
          Expanded(
            child: _buildCurrentStepWidget(),
          ),
        ],
      ),
    );
  }
}

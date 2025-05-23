import 'package:flutter/material.dart';
import 'package:rommaana_form/widgets/offer_details.dart';
import 'package:rommaana_form/widgets/step1_form.dart';
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
  Map<String, dynamic>? _offerDetails; // State variable to store offer details

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
              _currentStep++; // Advance to Step3Form
              print('Advancing from Step 1 to Step 3...');
            });
          },
        );
      case 1:
        return Step3Form(
          productId: _selectedProductId,
          onOfferCalculated: (Map<String, dynamic> data) {
            // Store the received offer details, but DO NOT change the step here
            setState(() {
              _offerDetails = data;
              print('MyHomePage received offer details after calculation: $_offerDetails');
            });
          },
          onPurchaseCompleted: () {
            // ONLY change the step when the purchase button is clicked
            setState(() {
              _currentStep++; // Advance to the OfferDetails screen
              print('Advancing to Offer Details Screen after purchase click...');
            });
          },
        );
      case 2: // Case for displaying offer details
        if (_offerDetails != null) {
          return OfferDetails(offerDetails: _offerDetails!);
        } else {
          return const Center(child: Text('No offer details available.'));
        }
      default:
        return const Center(child: Text('Form Completed!'));
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

import 'package:flutter/material.dart';
import 'package:rommaana_form/widgets/selectable_card.dart';
import 'package:rommaana_form/models/product_card_data.dart'; // Import the new data model

// Step 1 Form with selectable cards
class Step1Form extends StatefulWidget {
  // Callback function to send the selected card's integer ID to the parent
  final ValueChanged<int?> onCardSelected;
  // Callback function to notify the parent to advance to the next step
  final VoidCallback onStepCompleted;

  const Step1Form({
    super.key,
    required this.onCardSelected,
    required this.onStepCompleted, // Make the onStepCompleted callback required
  });

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  int? _selectedCardIndex; // State variable to keep track of the currently selected card index

  // Example data for the cards, parsed into ProductCardData objects
  // In a real app, this data would likely come from an API call
  final List<ProductCardData> _cardData = [
    ProductCardData.fromJson({
      "id": 13,
      "name": "Silver Home Insurance",
      "productId": "ROIN04TYHON13",
      "description": "This package provides the basic covers you need to secure your home if its value is within the range of 500,000.",
      "longDescription": "This package provides the basic covers you need to secure your home if its value is within the range of 500,000.\nThis product is offered by Al-Rajhi Takaful Insurance Company, one of the largest companies in the Saudi market, which is keen to design products compliant with Islamic Sharia.\n\nBenefits:\nAccidental Damage: SAR 250,000\nAlternative Accommodation & Loss of Rent: SAR 12,500\nHome Contents: SAR 25,000\nBurglary: SAR 12,500\nAccidental Death: SAR 25,000\nEstimation of prices: SAR 216",
      "type": "Home",
      "scoreRommaana": 8,
      "family": "9",
      "single": "8",
      "expat": "7",
      "img": "https://tlr.laz.mybluehost.me/website_9a064dbb/wp-content/uploads/2025/04/AlRajhi-Takaful2.png",
      "insurance_company_id": 4,
      "price_id": 2,
      "InsuranceCompany": {"name": "Al Rajhi Takaful"},
      "Price": {"lowerPrice": 200, "higherPrice": 300}
    }),
    ProductCardData.fromJson({
      "id": 14,
      "name": "Gold Home Insurance",
      "productId": "ROIN04TYHON14",
      "description": "This package offers basic coverage in addition to broader coverage to put your mind at ease from any loss that may affect your home, God forbid, if its value is within the range of 1,000,000.",
      "longDescription": "This package offers basic coverage in addition to broader coverage to put your mind at ease from any loss that may affect your home, God forbid, if its value is within the range: 1,000,000.\nThis product is offered by Al-Rajhi Takaful Insurance Company, one of the largest companies in the Saudi market, which is keen to design products compliant with Islamic Sharia.\n\nBenefits:\nAccidental Damage: SAR 500,000\nAlternative Accommodation & Loss of Rent: SAR 25,000\nHome Contents: SAR 50,000\nBurglary: SAR 25,000\nAccidental Death: SAR 50,000\nEstimation of prices: SAR 388",
      "type": "Home",
      "scoreRommaana": 8,
      "family": "8",
      "single": "8",
      "expat": "7",
      "img": "https://tlr.laz.mybluehost.me/website_9a064dbb/wp-content/uploads/2025/04/AlRajhi-Takaful2.png",
      "insurance_company_id": 4,
      "price_id": 1,
      "InsuranceCompany": {"name": "Al Rajhi Takaful"},
      "Price": {"lowerPrice": 100, "higherPrice": 200}
    }),
    ProductCardData.fromJson({
      "id": 15,
      "name": "Platinum Home Insurance",
      "productId": "ROIN04TYHON15",
      "description": "This package offers basic coverages in addition to wider coverages with higher coverage limits to suit the value of the house if its value is within the range of 2,000,000",
      "longDescription": "This package offers basic coverages in addition to wider coverages with higher coverage limits to suit the value of the house if its value is within the range of 2,000,000.\nThis product is offered by Al-Rajhi Takaful Insurance Company, one of the largest companies in the Saudi market, which is keen to design products compliant with Islamic Sharia.\n\nBenefits:\nAccidental Damage: SAR 1,000,000\nAlternative Accommodation & Loss of Rent: SAR 50,000\nReplacing Locks & Keys: SAR 1,000\nTracing a Leak: SAR 1,000\nEmergency Access: SAR 1,000\nHome Contents: SAR 100,000\nBurglary: SAR 50,000\nPersonal Possessions: SAR 5,000\nOwner’s Liability: SAR 100,000\nTenant’s Liability: SAR 25,000\nPersonal Money & Credit Cards: SAR 1,000\nPrams & Wheelchairs: SAR 1,000\nFood in Freezer or Refrigerator: SAR 1,000\nLoss of Personal Documents: SAR 1,000\nAccidental Death: SAR 100,000\nAccidental Death: SAR 20,000\nEmergency Medical Expenses: SAR 2,000\nExcess: SAR 200\nRepatriation: SAR 5,000\nEstimation of prices: SAR 690",
      "type": "Home",
      "scoreRommaana": 8,
      "family": "7",
      "single": "8",
      "expat": "9",
      "img": "https://tlr.laz.mybluehost.me/website_9a064dbb/wp-content/uploads/2025/04/AlRajhi-Takaful2.png",
      "insurance_company_id": 4,
      "price_id": 1,
      "InsuranceCompany": {"name": "Al Rajhi Takaful"},
      "Price": {"lowerPrice": 100, "higherPrice": 200}
    }),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine if the "Next" button should be enabled
    bool isNextButtonEnabled = _selectedCardIndex != null;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 1: Choose an Option',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Use ListView.builder for scrollable list of cards
          Expanded(
            child: ListView.builder(
              itemCount: _cardData.length,
              itemBuilder: (context, index) {
                final card = _cardData[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // Spacing between cards
                  child: SelectableCard(
                    data: card, // Pass the ProductCardData object
                    isSelected: _selectedCardIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedCardIndex = index;
                        // Pass the integer 'id' from the selected card data
                        widget.onCardSelected(card.id);
                        print('Selected: ${card.name} (ID: ${card.id})');
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Removed the "You selected: ..." text
          const SizedBox(height: 20), // Spacing before the button
          // "Next" button for Step 1
          ElevatedButton(
            onPressed: isNextButtonEnabled ? widget.onStepCompleted : null, // Call parent callback if enabled
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}


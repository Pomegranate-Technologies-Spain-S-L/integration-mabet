import 'package:flutter/material.dart';

class OfferDetails extends StatelessWidget {
  final Map<String, dynamic> offerDetails;

  const OfferDetails({
    super.key,
    required this.offerDetails,
  });

  // Helper widget to build a structured detail row
  Widget _buildDetailRow(String label, String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Adjusted width for labels
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                fontSize: isHeader ? 18 : 15,
                color: isHeader ? Colors.black : Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isHeader ? 18 : 15,
                color: isHeader ? Colors.black : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract relevant data for display based on the provided JSON structure
    final customer = offerDetails['Customer'] ?? {};
    final dataRequirement = offerDetails['DataRequirement'] ?? {};
    final product = offerDetails['Product'] ?? {};
    final offerPrice = offerDetails['offer_price']?.toStringAsFixed(2) ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0, // Remove shadow for a flatter look
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0), // Vertical padding only
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Congratulations!', // Main message
                style: TextStyle(
                  fontSize: 32, // Larger font size
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8), // Small space between messages
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Your Offer is Ready!', // Supporting message
                style: TextStyle(
                  fontSize: 20, // Smaller font size
                  color: Colors.grey.shade700, // Subtler color
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Price Card - now full width
            Card(
              elevation: 8.0, // Increased elevation for more prominence
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // More rounded corners
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20), // Keep some margin for the card itself
              child: Padding(
                padding: const EdgeInsets.all(25.0), // Increased padding inside the card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center content within the card
                  children: [
                    const Text(
                      'Final Price:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Row( // Use a Row to place the image and text side-by-side
                      mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
                      children: [
                        Image.network(
                          'https://srid7vtf90.ufs.sh/f/B7pTWizqIefFQlyMmotSGusKrtMLn1pWQPURXgElVBT8H4jy',
                          width: 40, // Adjust width for a larger icon to match the big text
                          height: 40, // Adjust height for a larger icon
                        ),
                        const SizedBox(width: 10), // Add some spacing between the image and the text
                        Text(
                          offerPrice,
                          style: TextStyle(
                            fontSize: 48, // Much larger font size
                            fontWeight: FontWeight.w900, // Extra bold
                            color: Theme.of(context).colorScheme.primary, // Primary color for highlight
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Offer ID: ${offerDetails['id']?.toString() ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      'Created At: ${offerDetails['created_at'] != null ? DateTime.parse(offerDetails['created_at']).toLocal().toString().split('.')[0] : 'N/A'}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Customer Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Customer Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const Divider(height: 20, thickness: 1.5, indent: 20, endIndent: 20),
            _buildDetailRow('Name', '${customer['name'] ?? 'N/A'} ${customer['lastName'] ?? ''}'),
            _buildDetailRow('Nationality', customer['nationality'] ?? 'N/A'),
            _buildDetailRow('National ID', customer['nationalId'] ?? 'N/A'),
            _buildDetailRow('Iqama', customer['iqama'] ?? 'N/A'),
            _buildDetailRow('Birthdate', customer['birthdate'] ?? 'N/A'),
            _buildDetailRow('Email', customer['email'] ?? 'N/A'),
            _buildDetailRow('Phone Number', customer['phoneNumber'] ?? 'N/A'),
            _buildDetailRow('Address', customer['address'] ?? 'N/A'),
            _buildDetailRow('Marital Status', customer['maritalStatus'] ?? 'N/A'),
            const SizedBox(height: 30),

            // Data Requirement Details Section (Based on actual DataRequirement object in JSON)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Data Requirement Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const Divider(height: 20, thickness: 1.5, indent: 20, endIndent: 20),
            _buildDetailRow('Previous Claims', dataRequirement['previous_claims']?.toString() ?? 'N/A'),
            _buildDetailRow('Previous Rejected', dataRequirement['previous_rejected']?.toString() ?? 'N/A'),
            _buildDetailRow('Policy Start Date', dataRequirement['policy_start_date'] ?? 'N/A'),
            const SizedBox(height: 30),

            // Product Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Product Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const Divider(height: 20, thickness: 1.5, indent: 20, endIndent: 20),
            _buildDetailRow('Product Name', product['name'] ?? 'N/A'),
            _buildDetailRow('Product ID', product['productId'] ?? 'N/A'),
            _buildDetailRow('Description', product['description'] ?? 'N/A'),
            _buildDetailRow('Long Description', product['longDescription'] ?? 'N/A'),
            _buildDetailRow('Type', product['type'] ?? 'N/A'),
            _buildDetailRow('Score Rommaana', product['scoreRommaana']?.toString() ?? 'N/A'),
            _buildDetailRow('Family', product['family'] ?? 'N/A'),
            _buildDetailRow('Single', product['single'] ?? 'N/A'),
            _buildDetailRow('Expat', product['expat'] ?? 'N/A'),
            // Display actual image from URL
            if (product['img'] != null && product['img'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Center(
                  child: Image.network(
                    product['img'],
                    width: 200, // Adjust width as needed
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Image failed to load');
                    },
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
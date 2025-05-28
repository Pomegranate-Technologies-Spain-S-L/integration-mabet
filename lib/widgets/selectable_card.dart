import 'package:flutter/material.dart';
import 'package:rommaana_form/models/product_card_data.dart';

class SelectableCard extends StatefulWidget {
  final ProductCardData data;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableCard({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SelectableCard> createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.isSelected ? 8.0 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: widget.isSelected ? Colors.blueAccent : Colors.grey.shade300,
          width: widget.isSelected ? 3.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.data.img,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Product ID: ${widget.data.productId}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4.0),
              // Name
              Text(
                widget.data.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  color: widget.isSelected ? Colors.blueAccent : Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8.0),
              // Description with expand/collapse
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isExpanded ? widget.data.longDescription : widget.data.description,
                      style: const TextStyle(fontSize: 14.0, color: Colors.black87),
                      maxLines: _isExpanded ? null : 3, // Show full text if expanded, else 3 lines
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                    if (widget.data.longDescription.length > widget.data.description.length) // Only show if there's more to expand
                      Text(
                        _isExpanded ? 'Show Less' : 'Show More',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Row( // Use a Row to align "Price Range:", the image, and the price values horizontally
                mainAxisSize: MainAxisSize.min, // Keep the row size to a minimum to wrap its content
                children: [
                  const Text(
                    'Price Range: ', // "Price Range: " as a separate Text widget
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Image.network(
                    'https://srid7vtf90.ufs.sh/f/B7pTWizqIefFQlyMmotSGusKrtMLn1pWQPURXgElVBT8H4jy',
                    width: 18, // Adjust width for a smaller icon
                    height: 18, // Adjust height for a smaller icon
                  ),
                  const SizedBox(width: 4), // Small spacing between image and price
                  Text(
                    '${widget.data.price['lowerPrice']} - ${widget.data.price['higherPrice']}',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Check icon if selected
              if (widget.isSelected)
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blueAccent,
                    size: 30.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:buying_list/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchasedItemSheet extends StatefulWidget {
  const PurchasedItemSheet({
    super.key,
    required this.itemName,
    this.desc,
    required this.id,
  });
  final String itemName;
  final String? desc;
  final String id;
  @override
  State<PurchasedItemSheet> createState() => _PurchasedItemSheetState();
}

class _PurchasedItemSheetState extends State<PurchasedItemSheet> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // handles keyboard
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // handle submit
                String location = _locationController.text;
                num price = num.parse(_priceController.text);
                await _firestore.collection(kPreviousPurchase).add({
                  'name': widget.itemName,
                  'description': widget.desc,
                  'price': price,
                  'location': location,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                await _firestore
                    .collection(kBuyingList)
                    .doc(widget.id)
                    .delete();

                // optionally close the modal
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

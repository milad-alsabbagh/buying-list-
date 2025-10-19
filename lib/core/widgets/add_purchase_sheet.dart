import 'package:buying_list/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPurchaseSheet extends StatefulWidget {
  const AddPurchaseSheet({super.key});

  @override
  State<AddPurchaseSheet> createState() => _AddPurchaseSheetState();
}

class _AddPurchaseSheetState extends State<AddPurchaseSheet> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
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
              controller: itemController,
              decoration: const InputDecoration(labelText: 'Item'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // handle submit
                String item = itemController.text;
                String desc = descController.text;
                num price = num.parse(_priceController.text);
                await _firestore.collection(kPreviousPurchase).add({
                  'name': item,
                  'description': desc,
                  'price': price,
                  'location': _locationController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // optionally close the modal
                Navigator.of(context).pop();
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

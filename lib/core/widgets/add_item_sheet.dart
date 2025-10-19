import 'package:buying_list/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController descController = TextEditingController();
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // handle submit
                String item = itemController.text;
                String desc = descController.text;
                _firestore.collection(kBuyingList).add({
                  'name': item,
                  'description': desc,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                print('Item: $item, Desc: $desc');

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

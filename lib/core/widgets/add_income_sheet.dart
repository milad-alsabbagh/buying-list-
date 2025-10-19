import 'package:buying_list/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddIncomeSheet extends StatefulWidget {
  const AddIncomeSheet({super.key});

  @override
  State<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<AddIncomeSheet> {
  final TextEditingController marketController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _transactionTypes = ['cash', 'card'];
  String? _selectedType;
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
              controller: marketController,
              decoration: const InputDecoration(labelText: 'Market name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'amount'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value:
                  _selectedType ??
                  _transactionTypes[0], // The currently selected value
              decoration: const InputDecoration(
                labelText: 'Transaction Type',
                // border:
                //     OutlineInputBorder(), // Gives it a TextField-like appearance
              ),
              items:
                  _transactionTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type), // Display "INCOME" or "OUTCOME"
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                  // If you somehow still needed typeController for some reason,
                  // you could update it here:
                  // typeController.text = newValue ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // handle submit
                String market = marketController.text;
                num amount = num.parse(amountController.text);
                _firestore.collection(kIncome).add({
                  'market': market,
                  'amount': amount,
                  'type': _selectedType ?? _transactionTypes[0],
                  'timestamp': FieldValue.serverTimestamp(),
                });
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

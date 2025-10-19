// market name
// amount
// cash/credit
import 'dart:developer';

import 'package:buying_list/core/constants.dart';
import 'package:buying_list/core/widgets/add_income_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class IncomeView extends StatefulWidget {
  IncomeView({super.key});

  @override
  State<IncomeView> createState() => _IncomeViewState();
}

class _IncomeViewState extends State<IncomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedMonth;
  @override
  Widget build(BuildContext context) {
    DateTime? startOfMonth =
        _selectedMonth != null
            ? DateTime(_selectedMonth!.year, _selectedMonth!.month, 1)
            : null;
    DateTime? endOfMonth =
        _selectedMonth != null
            ? DateTime(
              _selectedMonth!.year,
              _selectedMonth!.month + 1,
              1,
            ).subtract(const Duration(milliseconds: 1))
            : null;
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream:
                _selectedMonth != null
                    ? _firestore
                        .collection(kIncome)
                        .where(
                          'timestamp',
                          isGreaterThanOrEqualTo: startOfMonth,
                        )
                        .where('timestamp', isLessThanOrEqualTo: endOfMonth)
                        .orderBy('timestamp', descending: true)
                        .snapshots()
                    : _firestore
                        .collection(kIncome)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                log('${snapshot.data}');
                return Center(child: Text('No items found.'));
              }
              num totalPrice = 0.0;
              for (var document in snapshot.data!.docs) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String priceString = data['amount']?.toString() ?? '0.0';
                try {
                  totalPrice += num.parse(priceString);
                } catch (e) {
                  log('Error parsing');
                }
              }
              // Data is available, build the list
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(data['market'] ?? 'No market Name'),
                              subtitle: Text(
                                data['type'] ?? 'not defined ',
                              ), // Assuming 'name' field
                              trailing: Text(
                                data['amount'].toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 45,
                    color: Colors.greenAccent[700],
                    child: Center(
                      child: Text(
                        '${totalPrice.toStringAsFixed(2)} \$',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: ExpandableFab(
            children: [
              FloatingActionButton.small(
                onPressed: () async {
                  final DateTime? pickedMonth = await showMonthPicker(
                    context: context,
                    initialDate: _selectedMonth ?? DateTime.now(),

                    firstDate: DateTime(2000), // The earliest selectable month
                    lastDate: DateTime(2100), // The latest selectable month
                  );

                  if (pickedMonth != null && pickedMonth != _selectedMonth) {
                    setState(() {
                      _selectedMonth = pickedMonth; // Update the state
                    });
                  }
                },
                child: const Icon(
                  Icons.calendar_month,
                ), // Calendar icon for month selection
              ),
              FloatingActionButton.small(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // makes the sheet expand nicely
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return const AddIncomeSheet();
                    },
                  );
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }
}

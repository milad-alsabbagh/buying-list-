import 'dart:developer';
import 'package:buying_list/core/widgets/add_purchase_sheet.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import 'package:buying_list/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class PreviousPurchasesView extends StatefulWidget {
  PreviousPurchasesView({super.key});

  @override
  State<PreviousPurchasesView> createState() => _PreviousPurchasesViewState();
}

class _PreviousPurchasesViewState extends State<PreviousPurchasesView> {
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
                        .collection(kPreviousPurchase)
                        .where(
                          'timestamp',
                          isGreaterThanOrEqualTo: startOfMonth,
                        )
                        .where('timestamp', isLessThanOrEqualTo: endOfMonth)
                        .orderBy('timestamp', descending: true)
                        .snapshots()
                    : _firestore
                        .collection(kPreviousPurchase)
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
                String priceString = data['price']?.toString() ?? '0.0';
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
                      shrinkWrap: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(data['name'] ?? 'No Name'),
                              subtitle: Text(
                                data['description'] ?? 'no description ',
                              ), // Assuming 'name' field
                              trailing: Column(
                                children: [
                                  Text(
                                    data['price'].toString() == ''
                                        ? '0.0 \$'
                                        : '${data['price'].toString()} \$',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  Text(
                                    data['location'] == ''
                                        ? 'No location defined'
                                        : data['location'],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 45,
                    color: Colors.red[700],
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
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // makes the sheet expand nicely
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return const AddPurchaseSheet();
                    },
                  );
                },
                child: const Icon(
                  Icons.add,
                ), // Calendar icon for month selection
              ),
            ],
          ),
        );
      },
    );
  }
}

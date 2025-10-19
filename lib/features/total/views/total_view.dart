import 'package:buying_list/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:developer';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class TotalView extends StatefulWidget {
  const TotalView({super.key});

  @override
  _TotalViewState createState() => _TotalViewState();
}

class _TotalViewState extends State<TotalView> {
  @override
  void initState() {
    super.initState();
  }

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
    // Define your two streams
    Stream<QuerySnapshot> outcomeStream =
        _selectedMonth != null
            ? _firestore
                .collection(kPreviousPurchase)
                .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
                .where('timestamp', isLessThanOrEqualTo: endOfMonth)
                .orderBy('timestamp', descending: true)
                .snapshots()
            : _firestore
                .collection(kPreviousPurchase)
                .orderBy('timestamp', descending: true)
                .snapshots();

    Stream<QuerySnapshot> incomeStream =
        _selectedMonth != null
            ? _firestore
                .collection(kIncome) // Your income collection name
                .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
                .where('timestamp', isLessThanOrEqualTo: endOfMonth)
                .orderBy('timestamp', descending: true)
                .snapshots()
            : _firestore
                .collection(kIncome)
                .orderBy('timestamp', descending: true)
                .snapshots();

    return Scaffold(
      body: Center(
        // Center the entire content
        child: StreamBuilder<List<QuerySnapshot>>(
          stream: Rx.combineLatest2(
            outcomeStream,
            incomeStream,
            (QuerySnapshot outcomeSnap, QuerySnapshot incomeSnap) => [
              outcomeSnap,
              incomeSnap,
            ],
          ),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<QuerySnapshot>> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              );
            }

            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            // Data handling
            if (!snapshot.hasData || snapshot.data!.length < 2) {
              return Text('Waiting for data...');
            }

            // Extract the snapshots for outcome and income
            QuerySnapshot outcomeSnapshot = snapshot.data![0];
            QuerySnapshot incomeSnapshot = snapshot.data![1];

            // Calculate total outcome
            num totalOutcome = 0.0;
            if (outcomeSnapshot.docs.isNotEmpty) {
              for (var document in outcomeSnapshot.docs) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String priceString = data['price']?.toString() ?? '0.0';
                try {
                  totalOutcome += num.parse(priceString);
                } catch (e) {
                  log('Error parsing outcome price: $e');
                }
              }
            }

            // Calculate total income
            num totalIncome = 0.0;
            if (incomeSnapshot.docs.isNotEmpty) {
              for (var document in incomeSnapshot.docs) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String amountString = data['amount']?.toString() ?? '0.0';
                try {
                  totalIncome += num.parse(amountString);
                } catch (e) {
                  log('Error parsing income amount: $e');
                }
              }
            }

            // Calculate the net total
            num netTotal = totalIncome - totalOutcome;

            // Display the net total
            return Text(
              '${netTotal.toStringAsFixed(2)} \$',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: netTotal > 0 ? Colors.green : Colors.red,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}

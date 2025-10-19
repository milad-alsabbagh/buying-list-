import 'dart:developer';

import 'package:buying_list/core/constants.dart';
import 'package:buying_list/core/widgets/add_item_sheet.dart';
import 'package:buying_list/core/widgets/purshace_item_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BuyingListView extends StatelessWidget {
  BuyingListView({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .collection(kBuyingList)
                    .snapshots(), // The stream of data
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

              // Data is available, build the list
              return ListView(
                children:
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? 'No Name'),
                        subtitle: Text(
                          data['description'] ?? 'no description ',
                        ), // Assuming 'name' field
                        trailing: IconButton(
                          icon: Icon(Icons.done),
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled:
                                  true, // makes the sheet expand nicely
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (BuildContext context) {
                                return PurchasedItemSheet(
                                  itemName: data['name'],
                                  desc: data['description'],
                                  id: document.id,
                                );
                              },
                            );
                            // await _firestore
                            //     .collection('buying_list')
                            //     .doc(document.id)
                            //     .delete();
                          },
                        ),
                      );
                    }).toList(),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // makes the sheet expand nicely
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return const AddItemSheet();
                },
              );
              // Example: Add a new item to Firestore
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}

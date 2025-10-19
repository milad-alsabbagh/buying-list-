import 'package:buying_list/features/buying_list/views/buying_list_view.dart';
import 'package:buying_list/features/income/views/income_view.dart';
import 'package:buying_list/features/outcome/views/outcome_view.dart';
import 'package:buying_list/features/total/views/total_view.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    BuyingListView(),
    PreviousPurchasesView(),
    IncomeView(),
    TotalView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: GNav(
        selectedIndex: _selectedIndex,
        onTabChange:
            (value) => setState(() {
              _selectedIndex = value;
            }),

        tabs: [
          GButton(icon: Icons.shopping_bag_rounded, text: 'Buying List'),
          GButton(icon: Icons.money_off_csred_outlined, text: 'Expenses'),
          GButton(icon: Icons.payments_outlined, text: 'Income'),
          GButton(icon: Icons.functions_rounded, text: 'Total'),
        ],
      ),
    );
  }
}

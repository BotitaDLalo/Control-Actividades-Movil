import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<BottomNavigationBarItem> widgetsOptionsItems;
  const CustomNavbar(
      {super.key,
      required this.selectedIndex,
      required this.onItemSelected,
      required this.widgetsOptionsItems});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(canvasColor: Colors.white),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        items: widgetsOptionsItems,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}

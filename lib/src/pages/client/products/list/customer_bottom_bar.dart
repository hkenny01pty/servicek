import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final Function(int) onTap;
  final int selectedIndex;

  const CustomBottomBar({
    Key? key,
    required this.onTap,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 69,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIcon(Icons.account_circle_sharp, 0, 'Zona Cliente'),
            //_buildIcon(Icons.grid_view, 1, ''),
            _buildIcon(Icons.list, 2, 'Ordenes'),
            //_buildIcon(Icons.person, 3, 'Perfil'),
            _buildIcon(Icons.power_settings_new, 4, 'Salir'),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index, String label) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black,
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:servicek/src/pages/client/orders/list/client_orders_list_page.dart';
import 'package:servicek/src/pages/roles/roles_page.dart';
import 'package:servicek/src/pages/salir/salir_page.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';


class RolBottomBar extends StatelessWidget {
  final Function(int) onTap;
  final int selectedIndex;

  const RolBottomBar({
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
            _buildIcon(Icons.account_circle_sharp, 0, 'Inicio', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RolesPage()))),
            _buildIcon(Icons.list, 1, 'Ordenes Cli', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClientOrdersListPage()))),
            _buildIcon(Icons.call_rounded, 2, 'Operador', onTap: () => _launchPhoneCall('66668888', context)),
            _buildIcon(Icons.power_settings_new, 4, 'Salir', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SalirPage()))),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index, String label, {Function()? onTap}) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: onTap ?? () => this.onTap(index),
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

  Future<void>  _launchPhoneCall(String phoneNumber, context) async {
    //String phoneNumber = orderDetails['phone']?.toString() ?? '';
    if (phoneNumber.isNotEmpty) {
      bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      if (res != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo realizar la llamada')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de teléfono no disponible')),
      );
    }
  }

}
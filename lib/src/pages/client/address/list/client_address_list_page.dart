import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/pages/client/address/create/client_address_create_page.dart';

class ClientAddressListPage extends StatefulWidget {
  @override
  _ClientAddressListPageState createState() => _ClientAddressListPageState();
}

class _ClientAddressListPageState extends State<ClientAddressListPage> {
  String _userId = '';
  List<dynamic> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('Pantalla llamada - Dirección seleccionada: $_selectedAddress');
  }

  @override
  void didUpdateWidget(covariant ClientAddressListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadSelectedAddress();
  }

  Future<void> _loadUserIdAndAddresses() async {
    await _loadUserId();
    await _loadAddresses();
    _loadSelectedAddress();
  }

  Future<void> _loadUserId() async {
    Map<String, dynamic> userData = GetStorage().read('user') ?? {};
    Map<String, dynamic> userMap = userData['user'] ?? {};
    _userId = userMap['id'] ?? '';
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://www.aaservicek.com/servicek_backend/actions/address_actions.php?action=GET_ADDRESSES&id_user=$_userId'),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData is List) {
          setState(() {
            _addresses = decodedData;
            _isLoading = false;
          });
        } else if (decodedData is Map && decodedData.containsKey('addresses')) {
          setState(() {
            _addresses = decodedData['addresses'];
            _isLoading = false;
          });
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'No se pudieron cargar las direcciones: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _loadSelectedAddress() {
    _selectedAddress = GetStorage().read('selected_address');
    setState(() {});
    if (_selectedAddress == null) {
      Get.snackbar(
        'Sin dirección seleccionada',
        'No hay dirección seleccionada, por favor seleccione una.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
    }
    print('Dirección cargada: $_selectedAddress');
  }

  void _selectAddress(Map<String, dynamic> address) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmar dirección'),
        content: Text('¿Deseas seleccionar esta dirección para tu pedido?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('Aceptar'),
            onPressed: () {
              GetStorage().write('selected_address', address);
              setState(() {
                _selectedAddress = address;
              });
              Get.back();
              Get.snackbar(
                'Dirección seleccionada',
                'Tu pedido será enviado a esta dirección',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              print('Dirección seleccionada: $address');
            },
          ),
        ],
      ),
    );
  }


  void _deleteAddress(Map<String, dynamic> address) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar esta dirección?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('Eliminar'),
            onPressed: () async {
              Get.back();
              try {
                final response = await http.post(
                  Uri.parse('https://www.aaservicek.com/servicek_backend/actions/address_actions.php'),
                  body: {
                    'action': 'DELETE_ADDRESS',
                    'id_address': address['id'].toString(),
                    'id_user': _userId,
                  },
                );

                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');

                if (response.statusCode == 200) {
                  final result = json.decode(response.body);
                  if (result['success']) {
                    await _loadAddresses();
                    if (_selectedAddress == address) {
                      GetStorage().remove('selected_address');
                      setState(() {
                        _selectedAddress = null;
                      });
                    }
                    Get.snackbar(
                      'Éxito',
                      'Dirección eliminada correctamente',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    throw Exception(result['message']);
                  }
                } else {
                  throw Exception('Failed to delete address');
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'No se pudo eliminar la dirección: $e',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'MIS DIRECCIONES     ',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 3),
            Text(
              'Cant.: ${_addresses.length}',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.amber))
          : RefreshIndicator(
        onRefresh: _loadAddresses,
        child: _addresses.isEmpty
            ? Center(child: Text('No hay direcciones guardadas'))
            : ListView.builder(
          itemCount: _addresses.length,
          itemBuilder: (context, index) {
            final address = _addresses[index];
            final isSelected = _selectedAddress != null && _selectedAddress!['id'] == address['id'];
            return Stack(
              children: [
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${address['avenida_calle']}, ${address['ph_casa']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Apto/Casa:', '${address['apto_casa']}'),
                        _buildInfoRow('Corregimiento:', '${address['corregimiento']}'),
                        _buildInfoRow('Tipo:', '${address['tipo_vivienda']}'),
                        _buildInfoRow('Punto de referencia:', '${address['punto_referencia']}'),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red, size: 30),
                              onPressed: () => _deleteAddress(address),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, size: 30),
                              label: Text(isSelected ? 'Seleccionada' : 'Seleccionar'),
                              onPressed: () => _selectAddress(address),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: isSelected ? Colors.green : Colors.amber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            SizedBox(width: 30), // Para balancear el espacio del IconButton
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => ClientAddressCreatePage());
          _loadAddresses();
        },
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.amber,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

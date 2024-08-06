import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicek/src/pages/client/address/map/client_address_map_page.dart';
import 'package:get_storage/get_storage.dart';

class ClientAddressCreatePage extends StatefulWidget {
  @override
  _ClientAddressCreatePageState createState() => _ClientAddressCreatePageState();
}

class _ClientAddressCreatePageState extends State<ClientAddressCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String? _tipoVivienda;
  TextEditingController _avenidaCalleController = TextEditingController();
  TextEditingController _phCasaController = TextEditingController();
  TextEditingController _aptoNumeroController = TextEditingController();
  TextEditingController _corregimientoController = TextEditingController();
  TextEditingController _puntoReferenciaController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();

  late String _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() {
    Map<String, dynamic> userData = GetStorage().read('user') ?? {};
    Map<String, dynamic> userMap = userData['user'] ?? {};
    _userId = userMap['id'] ?? '';
    print(_userId);
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate() && _tipoVivienda != null) {
      final response = await http.post(
        Uri.parse('https://www.aaservicek.com/servicek_backend/actions/address_actions.php'),
        body: {
          'action': 'ADD_ADDRESS',
          'avenida_calle': _avenidaCalleController.text,
          'ph_casa': _phCasaController.text,
          'apto_casa': _aptoNumeroController.text,
          'corregimiento': _corregimientoController.text,
          'tipo_vivienda': _tipoVivienda!,
          'punto_referencia': _puntoReferenciaController.text,
          'latitud': _latitudeController.text,
          'longitud': _longitudeController.text,
          'id_user': _userId
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          Get.snackbar(
            'Éxito',
            'Dirección guardada correctamente',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Navigator.pop(context);
        } else {
          Get.snackbar(
            'Error',
            'Error al guardar la dirección: ${result['message']}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Error de conexión',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else if (_tipoVivienda == null) {
      Get.snackbar(
        'Error',
        'Por favor, seleccione un tipo de vivienda',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        title: Text(
          'NUEVA DIRECCIÓN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Icon(Icons.location_on, size: 60, color: Colors.amber),
              SizedBox(height: 20),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'INGRESA ESTA INFORMACIÓN',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        _buildTextField(
                          controller: _avenidaCalleController,
                          label: 'Avenida/Calle',
                          icon: Icons.add_road,
                          required: true,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _phCasaController,
                          label: 'PH / Casa',
                          icon: Icons.home,
                          required: true,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _aptoNumeroController,
                          label: 'Número Apto / Casa',
                          icon: Icons.home_work,
                          required: true,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _corregimientoController,
                          label: 'Corregimiento',
                          icon: Icons.location_city,
                        ),
                        SizedBox(height: 20),
                        Text('Tipo de vivienda:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        _buildTipoViviendaSelection(),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _puntoReferenciaController,
                          label: 'Punto de referencia',
                          icon: Icons.add_location,
                          onTap: _selectLocationOnMap,
                          readOnly: true,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _latitudeController,
                          label: 'Latitud',
                          icon: Icons.explore,
                          readOnly: true,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          controller: _longitudeController,
                          label: 'Longitud',
                          icon: Icons.explore,
                          readOnly: true,
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          child: Text(
                            'CREAR DIRECCIÓN',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _saveAddress,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.amber[700], size: 28),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.amber),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.amber, width: 2),
        ),
      ),
      validator: required ? (value) => value!.isEmpty ? 'Este campo es requerido' : null : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildTipoViviendaSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTipoViviendaOption('Casa', Icons.house),
        _buildTipoViviendaOption('Edificio', Icons.apartment),
        _buildTipoViviendaOption('PH', Icons.business),
      ],
    );
  }

  Widget _buildTipoViviendaOption(String tipo, IconData icon) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: _tipoVivienda == tipo ? Colors.amber : Colors.grey),
          onPressed: () => setState(() => _tipoVivienda = tipo),
        ),
        Text(tipo),
      ],
    );
  }

  Future<void> _selectLocationOnMap() async {
    final result = await Get.to(() => ClienAddressMapPage());
    if (result != null) {
      setState(() {
        _latitudeController.text = result['latitude'].toString();
        _longitudeController.text = result['longitude'].toString();
        _puntoReferenciaController.text = result['address'];
      });
    }
  }

  @override
  void dispose() {
    _avenidaCalleController.dispose();
    _phCasaController.dispose();
    _aptoNumeroController.dispose();
    _corregimientoController.dispose();
    _puntoReferenciaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}
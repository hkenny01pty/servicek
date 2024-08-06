import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'client_address_map_controller.dart';

class ClienAddressMapPage extends StatelessWidget {
  final ClientAddressMapController con = Get.put(ClientAddressMapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ubica tu dirección en el mapa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        actions: [
          PopupMenuButton<MapType>(
            icon: Icon(Icons.layers, color: Colors.black),
            onSelected: con.changeMapType,
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                value: MapType.normal,
                child: Text('Normal'),
              ),
              PopupMenuItem(
                value: MapType.satellite,
                child: Text('Satélite'),
              ),
              PopupMenuItem(
                value: MapType.terrain,
                child: Text('Terreno'),
              ),
              PopupMenuItem(
                value: MapType.hybrid,
                child: Text('Híbrido'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _googleMaps(),
          _buildAddressLabel(),
          _buildSelectPointButton(),
          // _buildZoomControls(), // Comentado según lo solicitado
        ],
      ),
    );
  }

  Widget _googleMaps() {
    return Obx(() =>
        GoogleMap(
          initialCameraPosition: con.initialPosition,
          mapType: con.mapType.value,
          onMapCreated: con.onMapCreate,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          markers: Set.of(con.markers),
          onCameraMove: con.onCameraMove,
          onCameraIdle: con.onCameraIdle,
        ));
  }

  Widget _buildAddressLabel() {
    return Positioned(
      top: 16.0,
      left: 16.0,
      right: 16.0,
      child: Obx(() {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            con.address.value,
            style: TextStyle(
              fontSize: 18.0,  // Aumentado el tamaño de la fuente
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }

  Widget _buildSelectPointButton() {
    return Positioned(
      bottom: 20.0,
      left: 0,
      right: 0,
      child: Center(
        child: FloatingActionButton.extended(
          onPressed: con.selectThisPoint,
          icon: Icon(Icons.pin_drop, color: Colors.black),  // Cambiado el icono a uno más intuitivo
          label: Text(
            'Seleccionar ubicación',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }

// Widget _buildZoomControls() {
//   return Positioned(
//     right: 20.0,
//     bottom: 100.0,
//     child: Column(
//       children: [
//         _buildZoomButton(Icons.add, () => con.zoomIn()),
//         SizedBox(height: 10),
//         _buildZoomButton(Icons.remove, () => con.zoomOut()),
//       ],
//     ),
//   );
// }

// Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
//   return Container(
//     height: 40.0,
//     width: 40.0,
//     child: FloatingActionButton(
//       heroTag: icon.codePoint.toString(),
//       mini: true,
//       onPressed: onPressed,
//       child: Icon(icon, color: Colors.black),
//       backgroundColor: Colors.white,
//     ),
//   );
// }
}
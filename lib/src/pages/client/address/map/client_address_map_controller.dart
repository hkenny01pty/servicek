import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;

class ClientAddressMapController extends GetxController {
  CameraPosition initialPosition = CameraPosition(
    target: LatLng(8.9989246, -79.5185367),
    zoom: 17,
  );

  var mapType = MapType.normal.obs;

  void changeMapType(MapType type) {
    mapType.value = type;
  }




  Completer<GoogleMapController> mapController = Completer();
  var markers = <Marker>[].obs;
  var address = ''.obs;

  loc.Location location = loc.Location();
  BitmapDescriptor? customIcon;

  @override
  void onInit() {
    super.onInit();
    _loadCustomMarker();
    _getCurrentLocation();
  }

  Future<void> _loadCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/img/my_location_yellow.png',
    );
  }

  void onMapCreate(GoogleMapController controller) {
    mapController.complete(controller);
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await location.getLocation();
      final latLng = LatLng(locationData.latitude!, locationData.longitude!);
      _updateCameraPosition(latLng);
      _addMarker(latLng);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _updateCameraPosition(LatLng position) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 17),
    ));
  }

  void _addMarker(LatLng position) {
    markers.clear();
    markers.add(Marker(
      markerId: MarkerId('currentLocation'),
      position: position,
      icon: customIcon ?? BitmapDescriptor.defaultMarker,
    ));
    updateAddressFromCoordinates(position);
  }

  void onCameraMove(CameraPosition position) {
    _addMarker(position.target);
  }

  void onCameraIdle() {
    updateAddressFromCoordinates(markers.first.position);
  }

  Future<void> updateAddressFromCoordinates(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      address.value = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
    } else {
      address.value = 'Dirección no encontrada';
    }

    // Imprimimos en consola para depuración
    developer.log('Latitud: ${position.latitude}');
    developer.log('Longitud: ${position.longitude}');
    developer.log('Dirección: ${address.value}');
  }

  // Método para seleccionar el punto y retornar los valores
  void selectThisPoint() {
    final LatLng selectedPosition = markers.first.position;
    final Map<String, dynamic> result = {
      'latitude': selectedPosition.latitude,
      'longitude': selectedPosition.longitude,
      'address': address.value,
    };

    // Imprimimos en consola los valores que se retornarán
    developer.log('Valores a retornar:');
    developer.log('Latitud: ${result['latitude']}');
    developer.log('Longitud: ${result['longitude']}');
    developer.log('Dirección: ${result['address']}');

    // Aquí retornamos los valores a la pantalla anterior
    Get.back(result: result);
  }


  void zoomIn() async {
  final GoogleMapController controller = await mapController.future;
  controller.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() async {
  final GoogleMapController controller = await mapController.future;
  controller.animateCamera(CameraUpdate.zoomOut());
  }

  }

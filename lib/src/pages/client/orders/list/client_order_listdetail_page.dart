import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../payment/client_payment_page.dart';
import 'client_orders_list_page.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientOrderListdetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const ClientOrderListdetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _ClientOrderListdetailPageState createState() => _ClientOrderListdetailPageState();
}

class _ClientOrderListdetailPageState extends State<ClientOrderListdetailPage> {
  Map<String, dynamic> orderDetails = {};
  List<Map<String, dynamic>> orderItems = [];
  static const IMAGE_BASE_URL2 = 'https://www.aaservicek.com/servicek_images/products';
  static const NO_IMAGE_URL = 'https://www.aaservicek.com/servicek_images/no-image.png';
  GoogleMapController? mapController;
  bool isMapExpanded = false;
  MapType _currentMapType = MapType.normal;
  LatLng? currentPosition;
  Set<Marker> _markers = {};

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _debounceTimer;
  static const _locationAccuracyThreshold = 20.0; // metros
  static const _debounceTime = Duration(seconds: 3);

  double _distanceInKm = 0.0;
  String _estimatedTime = '';

  @override
  void initState() {
    super.initState();
    orderDetails = Map<String, dynamic>.from(widget.order);
    fetchOrderDetails();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _debounceTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los servicios de ubicación están desactivados. Por favor, actívalos para continuar.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Los permisos de ubicación fueron denegados. Por favor, habilítalos en la configuración.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los permisos de ubicación fueron denegados permanentemente. Por favor, habilítalos en la configuración del dispositivo.')),
      );
      return;
    }

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
          (Position position) {
        if (position.accuracy <= _locationAccuracyThreshold) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(_debounceTime, () async {
            setState(() {
              currentPosition = LatLng(position.latitude, position.longitude);
            });
            await _updateMarkers();
            await _getPolyline();
          });
        }
      },
      onError: (error) {
        print("Error al obtener la ubicación: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la ubicación. Por favor, verifica los permisos y la configuración de GPS.')),
        );
      },
    );
  }

  Future<void> fetchOrderDetails() async {
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
      body: {
        'action': 'GET_ORDER_DETAILS',
        'order_id': orderDetails['numero_orden']?.toString() ?? '',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        orderDetails.addAll(data['order_details']);
        orderItems = List<Map<String, dynamic>>.from(data['order_items']);
      });
      _updateMarkers();
    } else {
      print('Error fetching order details: ${response.statusCode}');
    }
  }

  Future<void> updateOrderStatus() async {
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
      body: {
        'action': 'UPDATE_ORDER_STATUS_GENERICO',
        'order_id': orderDetails['numero_orden']?.toString() ?? '',
        'new_status': 'En Camino',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          orderDetails['status'] = 'En Camino';
        });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text('Se ha iniciado la entrega del pedido.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ClientOrdersListPage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el estado de la orden.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión al actualizar el estado de la orden.')),
      );
    }
  }

  Future<void> _updateMarkers() async {
    if (!mounted) return;

    double lat = double.tryParse(orderDetails['latitud']?.toString() ?? '0') ?? 0;
    double lng = double.tryParse(orderDetails['longitud']?.toString() ?? '0') ?? 0;

    try {
      BitmapDescriptor orderIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(38, 38)),
        'assets/img/my_location_yellow2.png',
      );

      BitmapDescriptor currentLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(30, 30)),
        'assets/img/delivery_little.png',
      );

      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('orderLocation'),
          position: LatLng(lat, lng),
          icon: orderIcon,
          infoWindow: const InfoWindow(title: 'Ubicación del pedido'),
        ));

        if (currentPosition != null) {
          _markers.add(Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentPosition!,
            icon: currentLocationIcon,
            infoWindow: const InfoWindow(title: 'Tu ubicación actual'),
          ));
        }
      });

      if (currentPosition != null && polylines.isEmpty) {
        await _getPolyline();
      }
    } catch (e) {
      print("Error al cargar los íconos de los marcadores: $e");
      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('orderLocation'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: const InfoWindow(title: 'Ubicación del pedido'),
        ));

        if (currentPosition != null) {
          _markers.add(Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Tu ubicación actual'),
          ));
        }
      });
    }
  }

  Future<void> _getPolyline() async {
    polylineCoordinates.clear();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyD8tg293nI8wg0_O0nBNsKAKEOTSHoxBfs',
      PointLatLng(currentPosition!.latitude, currentPosition!.longitude),
      PointLatLng(
        double.parse(orderDetails['latitud'] ?? '0'),
        double.parse(orderDetails['longitud'] ?? '0'),
      ),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    // Calcular la distancia total
    double totalDistance = 0;
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    // Convertir la distancia a kilómetros y redondear a 2 decimales
    _distanceInKm = double.parse((totalDistance / 1000).toStringAsFixed(2));

    // Calcular tiempo estimado (asumiendo una velocidad promedio de 30 km/h)
    double estimatedTimeInHours = _distanceInKm / 30;
    int hours = estimatedTimeInHours.floor();
    int minutes = ((estimatedTimeInHours - hours) * 60).round();
    _estimatedTime = '${hours > 0 ? '$hours h ' : ''}${minutes > 0 ? '$minutes min' : ''}';

    setState(() {
      polylines.clear();
      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3,
      );
      polylines[id] = polyline;
    });
  }

  void _onMapTypeButtonPressed(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  Future<void> _makePhoneCall() async {
    String phoneNumber = orderDetails['phone']?.toString() ?? '';
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

  void _sendWhatsAppMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando mensaje de WhatsApp al cliente...')),

    );
  }

  Future<void> launchWhatsAppMsg(String phone) async {
    final message = 'Hola, ¿cómo estás?'; // Mensaje opcional
    final whatsappUrl = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    print('WhatsApp URL: $whatsappUrl'); // Imprime la URL en la consola

    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('No se pudo abrir WhatsApp');
    }
  }

  void _centerMapOnUser() {
    if (currentPosition != null && mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPosition!, 15));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener tu ubicación actual')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Orden: ${orderDetails['numero_orden'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<MapType>(
              icon: const Icon(Icons.map),
              onSelected: _onMapTypeButtonPressed,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<MapType>>[
                const PopupMenuItem<MapType>(
                  value: MapType.normal,
                  child: Text('Normal'),
                ),
                const PopupMenuItem<MapType>(
                  value: MapType.satellite,
                  child: Text('Satélite'),
                ),
                const PopupMenuItem<MapType>(
                  value: MapType.terrain,
                  child: Text('Terreno'),
                ),
                const PopupMenuItem<MapType>(
                  value: MapType.hybrid,
                  child: Text('Híbrido'),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Expanded(
            flex: isMapExpanded ? 10 : 1,
            child: _buildMap(),
          ),
          _buildSummary(),
          if (!isMapExpanded)
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClientInfo(),
                      const SizedBox(height: 20),
                      _buildTotalAmount(),
                      const SizedBox(height: 20),
                      //_buildDeliveryButton(),
                      //_paymentButton(),
                      const SizedBox(height: 20),
                      _buildProductList(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    double lat = double.tryParse(orderDetails['latitud']?.toString() ?? '0') ?? 0;
    double lng = double.tryParse(orderDetails['longitud']?.toString() ?? '0') ?? 0;

    return Stack(
      children: [
        GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15,
          ),
          markers: _markers,
          polylines: Set<Polyline>.of(polylines.values),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            _updateMarkers();
          },
          onCameraMove: (_) => _updateMarkers(),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    isMapExpanded = !isMapExpanded;
                  });
                },
                child: Icon(isMapExpanded ? Icons.close : Icons.fullscreen),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _centerMapOnUser,
                child: Icon(Icons.my_location),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(Icons.directions_car, 'Distancia', '$_distanceInKm km'),
          _buildSummaryItem(Icons.access_time, 'Tiempo estimado', _estimatedTime),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildClientInfo() {
    String formattedDate = '';
    try {
      DateTime orderDate = DateTime.parse(orderDetails['fecha_hora_orden']?.toString() ?? '');
      formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(orderDate);
    } catch (e) {
      formattedDate = orderDetails['fecha_hora_orden']?.toString() ?? 'Fecha desconocida';
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${orderDetails['nombre_usuario'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Dirección: ${orderDetails['direccion_entrega'] ?? ''}'),
            const SizedBox(height: 4),
            Text('Corregimiento: ${orderDetails['corregimiento'] ?? ''}'),
            const SizedBox(height: 4),
            Text('Punto de referencia: ${orderDetails['punto_referencia'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Fecha y Hora de la Orden: $formattedDate'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Teléfono: ${orderDetails['phone'] ?? 'No disponible'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
           /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.call, color: Colors.white),
                  label: Text('Llamar', style: TextStyle(color: Colors.white)),
                  onPressed: _makePhoneCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.message, color: Colors.white),
                  label: Text('WhatsApp', style: TextStyle(color: Colors.white)),
                  onPressed: () => launchWhatsAppMsg(orderDetails['phone'] ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),*/
          ],
        ),
      ),
    );

  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos: (${orderItems.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ...orderItems.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      item['image1'] != null && item['image1'].toString().isNotEmpty
                          ? '$IMAGE_BASE_URL2/${item['image1']}'
                          : NO_IMAGE_URL,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nombre_producto']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Cantidad: ${item['cantidad_solicitada']?.toString() ?? ''}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Text(
      'Total a pagar: \$${orderDetails['monto_total']?.toString() ?? ''}',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
    );
  }

  Widget _buildDeliveryButtonx() {
    return ElevatedButton(
      onPressed: orderDetails['status'] == 'Despachado' ? updateOrderStatus : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Iniciar Entrega',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _paymentButtonx() {
    return ElevatedButton(
      onPressed: orderDetails['status'] == 'Entregado'
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientPaymentPage()),
        );
      }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Iniciar Pago',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}
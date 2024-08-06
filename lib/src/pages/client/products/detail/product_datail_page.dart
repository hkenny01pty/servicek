import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:servicek/src/models/product.dart';
import 'package:get_storage/get_storage.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final box = GetStorage();

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  List<String> _getProductImages() {
    List<String> images = [];
    if (widget.product.image1 != null && widget.product.image1!.isNotEmpty) {
      images.add(widget.product.image1!);
    }
    if (widget.product.image2 != null && widget.product.image2!.isNotEmpty) {
      images.add(widget.product.image2!);
    }
    if (widget.product.image3 != null && widget.product.image3!.isNotEmpty) {
      images.add(widget.product.image3!);
    }
    return images;
  }

  void _updateOrder() {
    List<dynamic> currentOrder = box.read('order') ?? [];

    int existingProductIndex = currentOrder.indexWhere((item) => item['id'] == widget.product.id);

    if (existingProductIndex >= 0) {
      currentOrder[existingProductIndex]['quantity'] = _quantity;
    } else {
      currentOrder.add({
        'id': widget.product.id,
        'name': widget.product.name,
        'price': widget.product.price,
        'quantity': _quantity,
        'image1': widget.product.image1,
      });
    }

    box.write('order', currentOrder);
  }

  void _addToOrder() {
    _updateOrder();

    List<dynamic> currentOrder = box.read('order') ?? [];
    print('Lista de productos en el pedido:');
    for (var product in currentOrder) {
      print('ID: ${product['id']}, Nombre: ${product['name']}, Precio: ${product['price']}, Cantidad: ${product['quantity']}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto agregado al pedido'),
        duration: Duration(seconds: 1),
      ),
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = _quantity * (widget.product.price ?? 0.0);
    List<String> productImages = _getProductImages();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name ?? 'Detalles del Producto'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    if (productImages.isNotEmpty)
                      CarouselSlider.builder(
                        itemCount: productImages.length,
                        itemBuilder: (context, index, realIdx) {
                          return Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.network(
                              'https://www.aaservicek.com/servicek_images/products/${productImages[index]}',
                              fit: BoxFit.cover,
                              height: 400,
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 370.0,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                      ),
                    if (productImages.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: productImages.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => setState(() {
                              _currentImageIndex = entry.key;
                            }),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == entry.key
                                    ? Colors.redAccent
                                    : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: Text(
                  widget.product.name ?? 'Nombre del Producto',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8.0),
              Center(
                child: Text(
                  widget.product.description ?? 'Descripción del Producto',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8.0),
              Center(
                child: Text(
                  '\$${widget.product.price ?? 0.0}',
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _decrementQuantity,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.remove, color: Colors.black),
                    ),
                  ),
                  Text(
                    '$_quantity',
                    style: TextStyle(fontSize: 20),
                  ),
                  GestureDetector(
                    onTap: _incrementQuantity,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                  Text(
                    'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addToOrder,
                  icon: Icon(Icons.shopping_bag),
                  label: Text('AGREGAR AL PEDIDO'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    primary: Colors.amber,
                    onPrimary: Colors.black,
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// client_products_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get/get.dart';
import 'package:servicek/src/models/product.dart';
import 'client_products_detail_controller.dart';

class ClientProductsDetailPage extends StatelessWidget {
  final Product product;
  late ClientProductsDetailController con;
  var counter = 0.obs;
  var price = 0.0.obs;

  ClientProductsDetailPage({required this.product}) {
    con = Get.put(ClientProductsDetailController());
  }

  @override
  Widget build(BuildContext context) {
    con.checkIfProductsWasAddes(product, price, counter);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: _productDetailsModal(context),
      ),
    );
  }

  Widget _productDetailsModal(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageSlideshow(context),
              _productDetails(context),
              Flexible(
                child: _buttonsAddToBag(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSlideshow(BuildContext context) {
    return ImageSlideshow(
      initialPage: 0,
      indicatorColor: Colors.amber[700],
      indicatorBackgroundColor: Colors.black,
      children: [
        FadeInImage(
          fit: BoxFit.cover,
          fadeInDuration: Duration(milliseconds: 50),
          placeholder: AssetImage('assets/img/no-image.png'),
          image: product.image1 != null
              ? NetworkImage(product.image1!)
              : AssetImage('assets/img/no-image.png') as ImageProvider,
        ),
        FadeInImage(
          fit: BoxFit.cover,
          fadeInDuration: Duration(milliseconds: 50),
          placeholder: AssetImage('assets/img/no-image.png'),
          image: product.image2 != null
              ? NetworkImage(product.image2!)
              : AssetImage('assets/img/no-image.png') as ImageProvider,
        ),
        FadeInImage(
          fit: BoxFit.cover,
          fadeInDuration: Duration(milliseconds: 50),
          placeholder: AssetImage('assets/img/no-image.png'),
          image: product.image3 != null
              ? NetworkImage(product.image3!)
              : AssetImage('assets/img/no-image.png') as ImageProvider,
        ),
      ],
    );
  }

  Widget _productDetails(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              product.description!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '# ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Obx(
                          () => Text(
                        '${counter.value}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonsAddToBag(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () => con.removeItem(product, price, counter),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Icon(
                Icons.remove,
                size: 24,
                color: Colors.grey[800],
              ),
            ),
          ),
          Obx(
                () => Text(
              '${counter.value}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () => con.addItem(product, price, counter),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber[700],
              ),
              child: Icon(
                Icons.add,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => con.addToBag(product, price, counter),
            style: ElevatedButton.styleFrom(
              primary: Colors.amber[700],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Agregar (Total:\$${price.value})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

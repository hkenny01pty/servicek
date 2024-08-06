import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicek/src/pages/salir/salir_controller.dart';

class SalirPage extends StatelessWidget {
  final SalirController controller = Get.put(SalirController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.amber.shade800,
                  size: 64.0,
                ),
              ),
              SizedBox(height: 32.0),
              Text(
                '¿Deseas salir de la sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // Regresa a la pantalla anterior
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade400,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: Text(
                      'Salir',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';



class NoDataWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;

  NoDataWidget({required this.text, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/cero-items.png',
            width: 150, // Tamaño de la imagen
          ),
          SizedBox(height: 20), // Espacio entre la imagen y el texto
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}



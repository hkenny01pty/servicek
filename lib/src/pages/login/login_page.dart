import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

LoginController con = Get.put(LoginController());

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _backgroundGradient(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40),
                  _logo(),
                  SizedBox(height: 40),
                  _loginForm(context),
                  SizedBox(height: 20),
                  _textDontHaveAccount(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.amber,
            Colors.amber[500]!,
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset('assets/img/delivery.png', fit: BoxFit.contain),
        ),
        SizedBox(height: 20),
        Text(
          'ServiceK',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loginForm(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar Sesión',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          _textFieldEmail(),
          SizedBox(height: 20),
          _textFieldPassword(),
          SizedBox(height: 30),
          _loginButton(),
          SizedBox(height: 15),
          _exitButton(),
        ],
      ),
    );
  }

  Widget _textFieldEmail() {
    return TextFormField(
      controller: con.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        prefixIcon: Icon(Icons.email, color: Colors.amber[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.amber[800]!, width: 2),
        ),
      ),
    );
  }

  Widget _textFieldPassword() {
    return TextFormField(
      controller: con.passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(Icons.lock, color: Colors.amber[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.amber[800]!, width: 2),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () => con.login(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(
          'INGRESAR',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _exitButton() {
    return TextButton(
      onPressed: () => Get.offAllNamed('/welcome'),
      child: Text(
        'SALIR',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textDontHaveAccount() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿No tienes cuenta? ',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          GestureDetector(
            onTap: () => con.goToRegisterPage(),
            child: Text(
              'Regístrate aquí',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterController con = Get.put(RegisterController());

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
                  _buttonBack(),
                  _imageUser(context),
                  SizedBox(height: 20),
                  _registerForm(context),
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
            Colors.amber,
          ],
        ),
      ),
    );
  }

  Widget _buttonBack() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(left: 20, top: 20),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _imageUser(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: GetBuilder<RegisterController>(
        builder: (value) => Column(
          children: [
            GestureDetector(
              onTap: () => con.showAlertDialog(context),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                backgroundImage: con.imageFile != null
                    ? FileImage(con.imageFile!)
                    : AssetImage('assets/img/user_profile.png') as ImageProvider,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 20,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              con.imageFile != null ? con.imageFile!.path.split('/').last : 'Toca para seleccionar imagen',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerForm(BuildContext context) {
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
            'Crear Cuenta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          _textField(con.emailController, 'Correo electrónico', Icons.email),
          SizedBox(height: 20),
          _textField(con.nameController, 'Nombre', Icons.person),
          SizedBox(height: 20),
          _textField(con.lastnameController, 'Apellido', Icons.person_outline),
          SizedBox(height: 20),
          _textField(con.phoneController, 'Teléfono', Icons.phone, keyboardType: TextInputType.phone),
          SizedBox(height: 20),
          _textField(con.passwordController, 'Contraseña', Icons.lock, isPassword: true),
          SizedBox(height: 20),
          _textField(con.confirmPasswordController, 'Confirmar Contraseña', Icons.lock_outline, isPassword: true),
          SizedBox(height: 30),
          _buttonRegister(context),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.amber),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.amber!, width: 2),
        ),
      ),
    );
  }

  Widget _buttonRegister(BuildContext context) {
    return ElevatedButton(
      onPressed: () => con.register(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(
          'REGISTRARSE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/pages/client/profile/info/client_profile_info_controller.dart';

class ClientProfileInfoPage extends StatelessWidget {
  ClientProfileInfoController con = Get.put(ClientProfileInfoController());

  @override
  Widget build(BuildContext context) {
    final userData = GetStorage().read('user') ?? {};

    return Scaffold(
      body: Stack(
        children: [
          _backgroundCover(context),
          _boxForm(context, userData),
          _imageUser(context, userData),
          Column(
            children: [
              //_buttonSignOut(userData),
              // _buttonRoles(userData), // Comentado
            ],
          ),
        ],
      ),
    );
  }

  Widget _backgroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.amber,
    );
  }

  Widget _boxForm(BuildContext context, Map<String, dynamic> userData) {
    final userValues = userData['user'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.30, left: 50, right: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 0.75),
          )
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _textName(userValues),
            _textEmail(userValues),
            _textPhone(userValues),
            _buttonUpdate(context, userValues),
            SizedBox(height: 16), // Espacio adicional
            _buttonRoles(context), // Nuevo botón "Roles"
          ],
        ),
      ),
    );
  }

  Widget _imageUser(BuildContext context, Map<String, dynamic> userData) {
    final userValues = userData['user'];

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 25),
        alignment: Alignment.topCenter,
        child: CircleAvatar(
          backgroundImage: userValues['image'] != null
              ? NetworkImage(userValues['image'])
              : AssetImage('assets/img/user_profile.png') as ImageProvider,
          radius: 75,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _textName(Map<String, dynamic> userValues) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text(
          '${userValues['name'] ?? ''} ${userValues['lastname'] ?? ''}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('Nombre del Usuario'),
      ),
    );
  }

  Widget _textPhone(Map<String, dynamic> userValues) {
    return ListTile(
      leading: Icon(Icons.phone),
      title: Text(
        userValues['phone'] ?? '',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('Phone'),
    );
  }

  Widget _textEmail(Map<String, dynamic> userValues) {
    return ListTile(
      leading: Icon(Icons.email),
      title: Text(
        userValues['email'] ?? '',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('Email'),
    );
  }

  Widget _buttonUpdate(BuildContext context, Map<String, dynamic> userValues) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      child: ElevatedButton(
        onPressed: () => con.goToProfileUpdate(),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          'Actualize aqui ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _buttonRoles(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 1),
      child: ElevatedButton(
        onPressed: () => con.goToRoles(),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          'Roles',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

/*
  Widget _buttonRoles(Map<String, dynamic> userData) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: () => con.goToRoles(),
        icon: Icon(
          Icons.supervised_user_circle,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
   */
}
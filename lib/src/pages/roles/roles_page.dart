import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/pages/login/login_page.dart';
import 'dart:convert';

import 'package:servicek/src/pages/roles/roles_controller.dart';
import 'package:servicek/src/pages/roles/rol_bottom_bar.dart';

import '../client/profile/info/client_profile_info_page.dart';

class RolesPage extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

RolesController con = Get.put(RolesController());

class _UserProfileScreenState extends State<RolesPage> {
  Map<String, dynamic>? userWithToken;
  int _selectedIndex = 0;
  final GetStorage _box = GetStorage();

  @override
  void initState() {
    super.initState();
    userWithToken = _box.read('user');
  }

  void _navigateToRoute(String route) {
    print('Navigating to: $route');
    Navigator.pushNamed(context, route);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _saveSelectedRole(String roleName) {
    _box.write('selected_role', roleName);
    print('Rol guardado en GetStorage. Key: "selected_role", Value: "$roleName"');
  }

  @override
  Widget build(BuildContext context) {
    if (userWithToken == null) {
      return Scaffold(
        body: Center(
          child: Text('No user data found'),
        ),
      );
    }

    final userData = userWithToken!['user'];
    final rolesJson = userData['roles'];
    final roles = rolesJson != null ? jsonDecode(rolesJson) : [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => con.signOut(),
        ),
        title: Row(
          children: [
            Text(
              'Seleccionar el Rol',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(userData, context),
              SizedBox(height: 24),
              if (roles.isNotEmpty)
                Text(
                  'Roles:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.amber.shade700,
                  ),
                ),
              if (roles.isNotEmpty)
                SizedBox(height: 16),
              _buildRolesGrid(roles),
            ],
          ),
        ),
      ),
      bottomNavigationBar: RolBottomBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }


Widget _buildUserInfo(Map<String, dynamic> userData, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClientProfileInfoPage()),
      );
    },
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userData['image']),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${userData['name']} ${userData['lastname']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(Icons.edit, color: Colors.blue),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: ${userData['email']}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Phone: ${userData['phone']}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



  Widget _buildRolesGrid(List roles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return _buildRoleCard(role);
      },
    );
  }

 Widget _buildRoleCard(Map<String, dynamic> role) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _saveSelectedRole(role['name']);
          _navigateToRoute(role['route']);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  role['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                role['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


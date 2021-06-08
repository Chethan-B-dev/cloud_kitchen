import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Cloud Kitchen'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Become a Seller'),
            onTap: () {
              Navigator.of(context).pushNamed('/seller');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Cart'),
            onTap: () {
              print("user is ${FirebaseAuth.instance.currentUser.uid}");
              Navigator.of(context).pushNamed('/cart');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              await authService.signOut();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          ),
        ],
      ),
    );
  }
}

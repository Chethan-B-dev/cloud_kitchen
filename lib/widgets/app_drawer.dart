import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// TODO:add name and email in app drawer

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'name',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'email',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Kitchen'),
            onTap: () async {
              await Kitchens().isSeller()
                  ? Navigator.of(context).pushNamed('/add-menu-items')
                  : Navigator.of(context).pushNamed('/seller');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Cart'),
            onTap: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              await AuthService().signOut();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delivery_dining),
            title: Text('Check Orders'),
            onTap: () {
              Navigator.of(context).pushNamed('/check-orders');
            },
          ),
        ],
      ),
    );
  }
}

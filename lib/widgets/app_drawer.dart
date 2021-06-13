import 'package:cloud_kitchen/services/cart.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:cloud_kitchen/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// TODO:add name and email in app drawer

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<Users>(
                  child: SizedBox(
                    height: 5,
                  ),
                  builder: (context, user, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        child,
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
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
              await Provider.of<Cart>(context, listen: false).clear();

              await AuthService().signOut();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          ),
          Divider(),
          FutureBuilder(
            future: Kitchens().isSeller(),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.data) {
                return ListTile(
                  leading: Icon(Icons.delivery_dining),
                  title: Text('Check Orders'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/check-orders');
                  },
                );
              } else {
                return Container();
              }
            },
          ),
          Divider(),
          FutureBuilder(
            future: Users().hasOrdered,
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.data) {
                return ListTile(
                  leading: Icon(Icons.delivery_dining),
                  title: Text('Order Status'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/order-status');
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

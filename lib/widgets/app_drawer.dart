import 'package:cloud_kitchen/services/cart.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:cloud_kitchen/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

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
                  child: const SizedBox(
                    height: 5,
                  ),
                  builder: (context, user, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        child,
                        Text(
                          user.email,
                          style: const TextStyle(
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Kitchen'),
            onTap: () async {
              await Kitchens().isSeller()
                  ? Navigator.of(context).pushNamed('/add-menu-items')
                  : Navigator.of(context).pushNamed('/seller');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Cart'),
            onTap: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              await Provider.of<Cart>(context, listen: false).clear();

              await AuthService().signOut();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
          ),
          const Divider(),
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
                  leading: const Icon(Icons.money_off_csred_rounded),
                  title: const Text('Check Orders'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/check-orders');
                  },
                );
              } else {
                return Container();
              }
            },
          ),
          const Divider(),
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
                  leading: const Icon(Icons.delivery_dining),
                  title: const Text('Order Status'),
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

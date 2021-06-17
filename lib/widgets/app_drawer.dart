import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/cart.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:cloud_kitchen/services/users.dart';
import 'package:cloud_kitchen/widgets/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var _isLoading = false;
  Map sellerDetails;

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
          ListTile(
            leading: const Icon(Icons.fastfood_rounded),
            title: const Text('Kitchen'),
            onTap: () async {
              await Kitchens().isSeller()
                  ? Navigator.of(context).pushNamed('/add-menu-items')
                  : Navigator.of(context).pushNamed('/seller');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
          FutureBuilder(
            future: Kitchens().isSeller(),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: const Icon(Icons.circle),
                  title: const Text('Loading'),
                );
              }
              if (snapshot.data) {
                return ListTile(
                  //top: 0, end: 3
                  leading: Badge(
                    animationDuration: Duration(milliseconds: 300),
                    animationType: BadgeAnimationType.slide,
                    badgeContent: FutureBuilder(
                      future: Kitchens().orderCount,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            '',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            '',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          );
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: snapshot.data,
                          builder: (context, ssnapshot) {
                            if (ssnapshot.hasError) {
                              return Text(
                                '',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            }
                            if (ssnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                '',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            }
                            return Text(
                              ssnapshot.data.docs.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    child: Icon(Icons.money),
                  ),
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
          FutureBuilder(
            future: Users().hasOrdered,
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: const Icon(Icons.circle),
                  title: const Text('Loading'),
                );
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
          ListTile(
            leading: _isLoading
                ? Icon(
                    Icons.circle_rounded,
                    color: Colors.yellow,
                  )
                : Icon(Icons.person),
            title: const Text('Edit profile'),
            onTap: () async {
              setState(() {
                _isLoading = true;
              });
              try {
                sellerDetails = await Kitchens().sellerDetails;
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => FullScreenDialog(
                      name: sellerDetails['username'],
                      email: sellerDetails['email'],
                      phone: sellerDetails['phone'],
                      address: sellerDetails['address'],
                    ),
                    fullscreenDialog: true,
                  ),
                );
              } catch (err) {
                ShowError.showError(err.toString(), context);
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text(
                  'Logout',
                  style: const TextStyle(
                    color: Colors.yellow,
                  ),
                ),
                content: const Text('Are You sure you want to logout?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await Provider.of<Cart>(context, listen: false).clear();
                      await AuthService().signOut();
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('No'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

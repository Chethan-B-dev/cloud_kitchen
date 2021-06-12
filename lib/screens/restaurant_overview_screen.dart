import 'package:badges/badges.dart';
import 'package:cloud_kitchen/services/cart.dart';
import 'package:cloud_kitchen/widgets/all_restaurants.dart';
import 'package:cloud_kitchen/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/search_bar.dart';
import '../widgets/new_restaurants.dart';
import '../helpers/hex_color.dart';
import '../services/auth_service.dart';

class RestaurantOverview extends StatelessWidget {
  RestaurantOverview({Key key}) : super(key: key);

  static const routeName = '/restaurants';
  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text(
        'Restaurants overview',
      ),
      actions: <Widget>[
        Consumer<Cart>(
          builder: (context, cart, child) => Badge(
            position: BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
            badgeContent: Text(
              cart.itemCount.toString(),
              style: TextStyle(color: Colors.white),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              content: const Text('Are You sure you want to logout?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await Provider.of<Cart>(context, listen: false).clear();
                    prefs = await SharedPreferences.getInstance();
                    prefs.clear();
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
          icon: Icon(
            Icons.logout,
            size: 26.0,
          ),
        )
      ],
    );

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          color: HexColor('#ECEFF1'),
        ),
        child: Column(
          children: [
            Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.1,
              child: SearchWidget(),
            ),
            Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.35,
              child: NewRestaurants(),
            ),
            Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.55,
              child: AllRestaurants(),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}

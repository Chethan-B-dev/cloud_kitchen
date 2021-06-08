import 'package:cloud_kitchen/widgets/all_restaurants.dart';
import 'package:cloud_kitchen/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/new_restaurants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './restaurant_detail_screen.dart';
import '../helpers/hex_color.dart';
import '../services/auth_service.dart';

class RestaurantOverview extends StatelessWidget {
  const RestaurantOverview({Key key}) : super(key: key);

  static const routeName = '/restaurants';

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    AppBar appBar = AppBar(
      title: Text(
        'Restaurants overview',
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () => showDialog<String>(
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
                      Navigator.pop(context, 'Cancel');
                      await authService.signOut();
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
            child: Icon(
              Icons.logout,
              size: 26.0,
            ),
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
            )
          ],
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}

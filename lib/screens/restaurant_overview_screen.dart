import 'package:flutter/material.dart';

class RestaurantOverview extends StatelessWidget {
  const RestaurantOverview({Key key}) : super(key: key);

  static const routeName = '/restaurants';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants overview'),
      ),
      body: Center(
        child: Text('hello user who has logged in wassup'),
      ),
    );
  }
}

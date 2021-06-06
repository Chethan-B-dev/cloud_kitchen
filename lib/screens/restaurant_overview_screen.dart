import 'package:cloud_kitchen/widgets/all_restaurants.dart';
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/new_restaurants.dart';

class RestaurantOverview extends StatelessWidget {
  const RestaurantOverview({Key key}) : super(key: key);

  static const routeName = '/restaurants';

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text('Restaurants overview'),
    );

    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
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
              child: PopularFoodsWidget(),
            ),
            Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.55,
              child: BestFoodWidget(),
            )
          ],
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

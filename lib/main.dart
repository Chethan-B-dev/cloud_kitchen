import 'package:cloud_kitchen/models/user.dart';
import 'package:cloud_kitchen/services/cart.dart';
import 'package:cloud_kitchen/services/users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './services/auth_service.dart';
import './screens/auth_screen.dart';
import './screens/restaurant_overview_screen.dart';
import './screens/restaurant_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_status_screen.dart';
import './screens/become_seller_screen.dart';
import './screens/add_menu_items.dart';
import './screens/add_food_item.dart';
import './screens/check_orders.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Users(),
        ),
        StreamProvider<UserModel>.value(
          value: AuthService().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Cloud Kitchen',
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        routes: <String, WidgetBuilder>{
          AuthScreen.routeName: (ctx) => AuthScreen(),
          RestaurantOverview.routeName: (ctx) => RestaurantOverview(),
          RestaurantDetail.routeName: (ctx) => RestaurantDetail(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrderStatus.routeName: (ctx) => OrderStatus(),
          BecomeSeller.routeName: (ctx) => BecomeSeller(),
          AddMenuItems.routeName: (ctx) => AddMenuItems(),
          FoodItem.routeName: (ctx) => FoodItem(),
          CheckOrders.routeName: (ctx) => CheckOrders(),
        },
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    Provider.of<Users>(context, listen: false).setup();
    if (user == null) {
      return AuthScreen();
    } else {
      return RestaurantOverview();
    }
  }
}

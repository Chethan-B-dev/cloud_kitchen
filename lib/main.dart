import 'package:cloud_kitchen/models/user.dart';
import 'package:cloud_kitchen/services/cart.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// TODO : add optimization to app by adding const
class MyApp extends StatelessWidget {
  final authService = new AuthService();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
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
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.black,
          errorColor: Colors.red,
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                button: TextStyle(
                  color: Colors.white,
                ),
              ),
        ),
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
    if (user == null) {
      return AuthScreen();
    } else {
      return RestaurantOverview();
    }
  }
}

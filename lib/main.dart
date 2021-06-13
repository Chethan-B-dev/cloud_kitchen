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

//refer these blogs for search after dinner
//https://medium.com/flutterdevs/implement-searching-with-firebase-firestore-flutter-de7ebd53c8c9
//https://medium.com/flutterdevs/search-data-in-flutter-using-cloud-firestore-search-delegate-1a46c703384
//https://www.youtube.com/watch?v=0szEJiCUtMM
//https://github.com/rajayogan/flutterfirestore-instantsearch/tree/master/lib
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// TODO : add optimization to app by adding const
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
    Provider.of<Users>(context, listen: false).setup();
    if (user == null) {
      return AuthScreen();
    } else {
      return RestaurantOverview();
    }
  }
}

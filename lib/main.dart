import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './screens/auth_screen.dart';
//import './screens/starter_page.dart';
import './screens/restaurant_overview_screen.dart';
import './screens/restaurant_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_status_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return MaterialApp(
          title: 'cloud Kitchen',
          theme: ThemeData(
            primarySwatch: Colors.pink,
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
          home: isLoggedIn ? RestaurantOverview() : AuthScreen(),
          routes: {
            AuthScreen.routeName: (ctx) => AuthScreen(),
            RestaurantOverview.routeName: (ctx) => RestaurantOverview(),
            RestaurantDetail.routeName: (ctx) => RestaurantDetail(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderStatus.routeName: (ctx) => OrderStatus(),
          },
        );
      },
    );
  }
}

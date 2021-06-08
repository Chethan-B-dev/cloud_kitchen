import 'package:cloud_kitchen/models/user.dart';
import 'package:cloud_kitchen/screens/starter_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './screens/auth_screen.dart';
//import './screens/starter_page.dart';
import './screens/restaurant_overview_screen.dart';
import './screens/restaurant_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_status_screen.dart';
import './screens/become_seller_screen.dart';
import './screens/add_menu_items.dart';
import 'package:provider/provider.dart';
import './services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseAuth.instance.idTokenChanges(),
//       builder: (context, snapshot) {
//         bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//         return MaterialApp(
//           title: 'cloud Kitchen',
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(
//             primarySwatch: Colors.purple,
//             accentColor: Colors.black,
//             errorColor: Colors.red,
//             textTheme: ThemeData.light().textTheme.copyWith(
//                   title: TextStyle(
//                     fontFamily: 'OpenSans',
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                   button: TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//           ),
//           home: isLoggedIn ? StarterPage() : AuthScreen(),
//           routes: {
//             AuthScreen.routeName: (ctx) => AuthScreen(),
//             RestaurantOverview.routeName: (ctx) => RestaurantOverview(),
//             RestaurantDetail.routeName: (ctx) => RestaurantDetail(),
//             CartScreen.routeName: (ctx) => CartScreen(),
//             OrderStatus.routeName: (ctx) => OrderStatus(),
//             BecomeSeller.routeName: (ctx) => BecomeSeller(),
//             AddMenuItems.routeName: (ctx) => AddMenuItems(),
//           },
//         );
//       },
//     );
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthService().user,
      initialData: null,
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
        routes: {
          AuthScreen.routeName: (ctx) => AuthScreen(),
          RestaurantOverview.routeName: (ctx) => RestaurantOverview(),
          RestaurantDetail.routeName: (ctx) => RestaurantDetail(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrderStatus.routeName: (ctx) => OrderStatus(),
          BecomeSeller.routeName: (ctx) => BecomeSeller(),
          AddMenuItems.routeName: (ctx) => AddMenuItems(),
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
    print("user $user");
    if (user == null) {
      print('came inside if');
      return AuthScreen();
    } else {
      print('came inside else');
      return RestaurantOverview();
    }
  }
}

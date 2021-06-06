import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './screens/auth_screen.dart';
import './screens/starter_page.dart';
import './screens/restaurant_overview_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cloud Kitchen',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.orange,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong'),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, user) {
                if (user.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (user == null) {
                  return AuthScreen();
                } else {
                  return StarterPage();
                }
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      routes: {
        AuthScreen.routeName: (ctx) => AuthScreen(),
        RestaurantOverview.routeName: (ctx) => RestaurantOverview(),
      },
    );
  }
}

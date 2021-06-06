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
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, user) {
          if (user.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (user == null) {
            return FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return AuthScreen();
                }
              },
            );
          } else {
            return FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return StarterPage();
                }
              },
            );
          }
        },
      ),
      routes: {
        AuthScreen.routeName: (ctx) => AuthScreen(),
        RestaurantOverview.routeName: (ctx) => RestaurantOverview(),
      },
    );
  }
}

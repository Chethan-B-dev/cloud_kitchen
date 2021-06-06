import 'package:flutter/material.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.orange,
      ),
      home: AuthScreen(),
      routes: {AuthScreen.routeName: (ctx) => AuthScreen()},
    );
  }
}

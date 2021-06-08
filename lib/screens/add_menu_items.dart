import 'package:flutter/material.dart';

class AddMenuItems extends StatefulWidget {
  const AddMenuItems({Key key}) : super(key: key);

  static String routeName = '/add-menu-items';

  @override
  _AddMenuItemsState createState() => _AddMenuItemsState();
}

class _AddMenuItemsState extends State<AddMenuItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Menu Items',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/food');
            },
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Add menu items',
        ),
      ),
    );
  }
}

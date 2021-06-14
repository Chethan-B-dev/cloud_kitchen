import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowError {
  static void showError(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Error!',
          style: const TextStyle(
            color: Colors.yellow,
          ),
        ),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            // textColor: Colors.yellow,
            child: const Text('Okay'),
            onPressed: () {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
          )
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowError {
  static void showError(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'An Error Occurred!',
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.green,
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

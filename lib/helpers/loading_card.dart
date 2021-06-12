import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/placeholder_lines.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 9,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        width: double.infinity,
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.6),
              ),
              child: Center(
                child: Icon(
                  Icons.photo_size_select_actual,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
            Expanded(
              child: PlaceholderLines(
                count: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

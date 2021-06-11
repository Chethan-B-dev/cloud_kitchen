import 'package:flutter/material.dart';

class BorderRed extends Decoration {
  Widget get border {
    BoxDecoration(
      border: Border.all(
        color: Colors.red,
      ),
    );
  }

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    // TODO: implement createBoxPainter
    throw UnimplementedError();
  }
}

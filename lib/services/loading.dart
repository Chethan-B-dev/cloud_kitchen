import 'package:flutter/cupertino.dart';

class Load with ChangeNotifier {
  var isLoading = false;
  void changeIsLoading() {
    isLoading = !isLoading;
  }
}

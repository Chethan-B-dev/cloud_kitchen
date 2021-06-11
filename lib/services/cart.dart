import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String foodId;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;

  const CartItem({
    @required this.foodId,
    @required this.title,
    @required this.quantity,
    @required this.imageUrl,
    @required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> jsonData) => CartItem(
        foodId: jsonData['foodId'],
        title: jsonData['title'],
        imageUrl: jsonData['imageUrl'],
        price: jsonData['price'],
        quantity: jsonData['quantity'],
      );

  static Map<String, dynamic> toMap(CartItem cart) => {
        'foodId': cart.foodId,
        'title': cart.title,
        'imageUrl': cart.imageUrl,
        'price': cart.price,
        'quantity': cart.quantity,
      };

  static String encode(List<CartItem> items) => json.encode(
        items
            .map<Map<String, dynamic>>((item) => CartItem.toMap(item))
            .toList(),
      );

  static List<CartItem> decode(String items) =>
      (json.decode(items) as List<dynamic>)
          .map<CartItem>((item) => CartItem.fromJson(item))
          .toList();
}

class Cart with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('foods');
  SharedPreferences prefs;

  Cart() {
    print('Default provider of cart was called');
    setup();
  }
  void setup() async {
    prefs = await SharedPreferences.getInstance();
    List<CartItem> cart = CartItem.decode(prefs.getString('cart'));
    cart.forEach((item) {
      _items[item.foodId] = item;
    });
    print(items);
    notifyListeners();
  }

  Future<String> get userName async {
    try {
      final snapshot = await _mainCollection.doc(userId).get();
      final result = snapshot.data() as Map<String, dynamic>;
      return result['username'];
    } catch (err) {
      print(err.toString());
      throw (err.toString());
    }
  }

  String get userId {
    return FirebaseAuth.instance.currentUser.uid;
  }

  static Map<String, CartItem> _items = {};
  String _kitchenId = '';

  String get kitchenId => _kitchenId;

  set kitchenId(String kitchenId) {
    _kitchenId = kitchenId;
  }

  Map<String, CartItem> get items {
    return {..._items};
  }

  bool checkKitchenID(String newKitchenID) {
    if (kitchenId == '') {
      kitchenId = newKitchenID;
      return true;
    }
    return newKitchenID == _kitchenId;
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> addItem(String foodId) async {
    try {
      final snapshot = await _foodCollection
          .doc(kitchenId)
          .collection('items')
          .doc(foodId)
          .get();

      final result = snapshot.data() as Map<String, dynamic>;

      print(result);

      String title = result['name'];
      double price = result['price'];
      String imageUrl = result['imageUrl'];

      await _cartCollection.doc(userId).collection('items').add(
        {
          'quantity': 1,
          'foodId': foodId,
        },
      );

      if (_items.containsKey(foodId)) {
        _items.update(
          foodId,
          (existingCartItem) => CartItem(
            foodId: existingCartItem.foodId,
            title: existingCartItem.title,
            price: existingCartItem.price,
            imageUrl: existingCartItem.imageUrl,
            quantity: existingCartItem.quantity + 1,
          ),
        );
      } else {
        _items.putIfAbsent(
          foodId,
          () => CartItem(
            foodId: foodId,
            title: title,
            price: price,
            quantity: 1,
            imageUrl: imageUrl,
          ),
        );
      }

      prefs = await SharedPreferences.getInstance();
      List<CartItem> temp = [];
      items.forEach((key, value) {
        temp.add(value);
      });

      prefs.setString('cart', CartItem.encode(temp));

      notifyListeners();
    } on PlatformException catch (err) {
      var message = 'An error occurred, please try again later!';

      if (err.message != null) {
        message = err.message;
      }
      throw (message);
    } catch (error) {
      throw (error.toString());
    }
  }

  void removeItem(String productId) async {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() async {
    _items = {};
    notifyListeners();
  }
}

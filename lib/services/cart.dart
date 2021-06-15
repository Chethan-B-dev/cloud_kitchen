import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/config.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class CartItem {
  final String foodId;
  final String cartId;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;

  const CartItem({
    @required this.foodId,
    @required this.cartId,
    @required this.title,
    @required this.quantity,
    @required this.imageUrl,
    @required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> jsonData) => CartItem(
        foodId: jsonData['foodId'],
        cartId: jsonData['cartId'],
        title: jsonData['title'],
        imageUrl: jsonData['imageUrl'],
        price: jsonData['price'],
        quantity: jsonData['quantity'],
      );

  static Map<String, dynamic> toMap(CartItem cart) => {
        'foodId': cart.foodId,
        'cartID': cart.cartId,
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
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('foods');
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference _kitchensCollection =
      FirebaseFirestore.instance.collection('kitchens');

  SharedPreferences prefs;

  Cart() {
    setup();
  }

  void setup() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('cart')) {
      List<CartItem> cart = CartItem.decode(prefs.getString('cart'));
      cart.forEach((item) {
        _items[item.foodId] = item;
      });
    }
    if (prefs.containsKey('kitchenId')) {
      kitchenId = prefs.getString('kitchenId');
    }
    notifyListeners();
  }

  Future<String> get userName async {
    try {
      final snapshot = await _mainCollection.doc(userId).get();
      final result = snapshot.data() as Map<String, dynamic>;
      return result['username'];
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

  Future<bool> checkKitchenID(String newKitchenID) async {
    try {
      if (kitchenId == '') {
        kitchenId = newKitchenID;
        return true;
      }

      prefs = await SharedPreferences.getInstance();
      prefs.setString('kitchenId', kitchenId);
      return newKitchenID == _kitchenId;
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

  int get itemCount {
    return _items.length;
  }

  Future mail(String email, String msg) async {
    String username = Config.email; //Your Email;
    String password = Config.password; //Your Email's password;

    final smtpServer = gmail(username, password);
    // Creating the Gmail server

    // Create our email message.
    final message = Message()
      ..from = Address(username)
      ..recipients.add(email)
      ..subject =
          'New Order - Cloud Kitchen :: 😀 :: ${DateTime.now()}' //subject of the email
      ..text = msg; //body of the email

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' +
          sendReport.toString()); //print if the email is sent
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      throw e; //print if the email is not sent
      // e.toString() will show why the email is not sending
    } catch (err) {
      throw err;
    }
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> deleteOrder(
    String orderId,
    String userId,
    bool isCancelled,
  ) async {
    try {
      await _ordersCollection
          .doc(await Kitchens().kitchenId)
          .collection('orders')
          .doc(orderId)
          .delete();

      if (!isCancelled) {
        await _mainCollection.doc(userId).update({
          'hasOrdered': true,
          'orderStatus': json.encode({
            await Kitchens().kitchenId: '3',
          }),
        });
      } else {
        await _mainCollection.doc(userId).update({
          'hasOrdered': true,
          'orderStatus': json.encode({
            await Kitchens().kitchenId: '4',
          }),
        });
      }
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

  Future<void> addItem(String foodId) async {
    try {
      final snapshot = await _foodCollection
          .doc(kitchenId)
          .collection('items')
          .doc(foodId)
          .get();

      final result = snapshot.data() as Map<String, dynamic>;

      String title = result['name'];
      double price = result['price'];
      String imageUrl = result['imageUrl'];

      final existingDoc = await _cartCollection
          .doc(userId)
          .collection('items')
          .where('foodId', isEqualTo: foodId)
          .get();

      DocumentReference doc;

      if (existingDoc.docs.length == 0) {
        doc = await _cartCollection.doc(userId).collection('items').add(
          {
            'quantity': 1,
            'foodId': foodId,
          },
        );
      } else {
        final existingQuanity =
            (existingDoc.docs[0].data() as Map<String, dynamic>)['quantity'];
        existingDoc.docs[0].reference.update({
          'quantity': existingQuanity + 1,
        });
      }

      if (_items.containsKey(foodId)) {
        _items.update(
          foodId,
          (existingCartItem) => CartItem(
            cartId: existingCartItem.cartId,
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
            cartId: doc.id,
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

  Future<void> _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  Future<String> placeOrder() async {
    try {
      final doc = await _kitchensCollection.doc(kitchenId).get();
      final phoneNumber =
          (doc.data() as Map<String, dynamic>)['phone'] as String;
      final email = (doc.data() as Map<String, dynamic>)['email'] as String;
      String message = "I have placed an ordered in your kitchen!";
      List<String> recipents = [phoneNumber];

      await _sendSMS(message, recipents);

      String user = await userName;

      await mail(email, "You have a new order from $user");

      Map<String, int> orderItemData = {};

      items.forEach((key, value) {
        orderItemData[key] = value.quantity;
      });

      await _mainCollection.doc(userId).update({
        'hasOrdered': true,
        'orderStatus': json.encode({
          kitchenId: '0',
        }),
      });

      await _ordersCollection.doc(kitchenId).collection('orders').add({
        'userId': userId,
        'username': await userName,
        'items': json.encode(orderItemData),
      });

      return kitchenId;
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

  Future<void> decQuantity(String foodId, String cartId) async {
    try {
      _items.update(
        foodId,
        (existingCartItem) {
          if (existingCartItem.quantity == 1) {
            removeItem(cartId, foodId).then(
              (value) => print('item removed'),
            );
          }

          return CartItem(
            cartId: existingCartItem.cartId,
            foodId: existingCartItem.foodId,
            title: existingCartItem.title,
            price: existingCartItem.price,
            imageUrl: existingCartItem.imageUrl,
            quantity: existingCartItem.quantity - 1,
          );
        },
      );

      final doc = await _cartCollection
          .doc(userId)
          .collection('items')
          .doc(cartId)
          .get();

      if (doc.exists) {
        await doc.reference.update({
          'quantity': (doc.data() as Map<String, dynamic>)['quantity'] - 1,
        });
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

  Future<void> removeItem(String cartId, String foodId) async {
    try {
      await _cartCollection
          .doc(userId)
          .collection('items')
          .doc(cartId)
          .delete();

      _items.remove(foodId);

      if (itemCount == 0) {
        await clear();
      } else {
        prefs = await SharedPreferences.getInstance();
        List<CartItem> temp = [];
        items.forEach((key, value) {
          temp.add(value);
        });
        prefs.setString('cart', CartItem.encode(temp));
      }
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

  Future<void> clear() async {
    try {
      final snapshot =
          await _cartCollection.doc(userId).collection('items').get();
      final list = snapshot.docs;

      list.forEach((element) {
        element.reference.delete();
      });

      _items = {};
      kitchenId = '';
      prefs = await SharedPreferences.getInstance();
      prefs.remove('cart');
      prefs.remove('kitchenId');
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

  List<dynamic> isInCart(String foodId) {
    if (items.containsKey(foodId)) {
      return [true, items[foodId].cartId];
    } else {
      return [false, null];
    }
  }
}

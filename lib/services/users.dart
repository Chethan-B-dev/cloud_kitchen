import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Users with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('food');
  final CollectionReference _kitchenCollection =
      FirebaseFirestore.instance.collection('kitchens');
  SharedPreferences prefs;

  String username = "";
  String uid = "";
  String email = "";

  Users() {
    setup();
  }

  //* added try catch in setup if error comes remove it

  void setup() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('username')) {
      username = prefs.getString('username');
    } else {
      username = await userName;
    }
    if (prefs.containsKey('userId')) {
      uid = prefs.getString('userId');
    }
    if (prefs.containsKey('email')) {
      email = prefs.getString('email');
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

  Future<bool> get hasOrdered async {
    try {
      final snapshot = await _mainCollection.doc(userId).get();
      final result = snapshot.data() as Map<String, dynamic>;
      return result['hasOrdered'];
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

  // TODO - implement provider username ,email and userid

  Stream<Map> orderStatus() {
    Map data;
    return _mainCollection
        .doc(userId)
        .snapshots()
        .map((DocumentSnapshot<Object> snapshot) {
      data =
          json.decode((snapshot.data() as Map<String, dynamic>)['orderStatus']);
      return data;
    });
  }

  String get userId {
    return FirebaseAuth.instance.currentUser.uid;
  }

  Future<void> completeOrder(String kitchenId, bool skipped, num rating) async {
    try {
      await _mainCollection.doc(userId).update({
        'hasOrdered': false,
        'orderStatus': '',
      });

      if (!skipped) {
        final snapshot = await _kitchenCollection.doc(kitchenId).get();
        final existingRating =
            (snapshot.data() as Map<String, dynamic>)['rating'];
        final existingNoOfRated =
            (snapshot.data() as Map<String, dynamic>)['noOfRating'];
        await snapshot.reference.update({
          'rating': existingRating + rating,
          'noOfRating': existingNoOfRated + 1,
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

  Future addFoodToCart(String kitchenId, String foodId) async {
    try {
      DocumentReference document =
          await _cartCollection.doc(userId).collection('items').add(
        {
          'quantity': 1,
          'foodId': foodId,
          'kitchenId': kitchenId,
        },
      );

      return document.id;
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
}

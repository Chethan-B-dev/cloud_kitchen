import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Users with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');

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

  Future<bool> get hasOrdered async {
    try {
      final snapshot = await _mainCollection.doc(userId).get();
      final result = snapshot.data() as Map<String, dynamic>;
      return result['hasOrdered'];
    } catch (err) {
      print(err.toString());
      throw (err.toString());
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

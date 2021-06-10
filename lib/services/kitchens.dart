import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Kitchens with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('kitchens');
  final CollectionReference _secCollection =
      FirebaseFirestore.instance.collection('users');

  String get userId {
    return _auth.currentUser.uid;
  }

  Future<Map<String, dynamic>> get sellerDetails async {
    final snapshot = await _secCollection.doc(userId).get();
    return snapshot.data();
  }

  Future<bool> isSeller() async {
    final data = await sellerDetails;
    return data['isSeller'];
  }

  Future addKitchen(
    String kname,
    bool isNonVeg,
  ) async {
    try {
      Map<String, dynamic> userDetails = await sellerDetails;

      DocumentReference document = await _mainCollection.add(
        {
          'kname': kname,
          'userId': userId,
          'username': userDetails['username'],
          'email': userDetails['email'],
          'phone': userDetails['phone'],
          'address': userDetails['address'],
          'isVeg': !isNonVeg,
          'rating': 0.0
        },
      );

      await _secCollection.doc(userId).update(
        {
          'kitchenId': document.id,
          'isSeller': true,
        },
      );
    } on PlatformException catch (err) {
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = err.message;
      }
      throw (message);
    } catch (error) {
      throw ('Could not authenticate you. Please try again later.');
    }
  }
}

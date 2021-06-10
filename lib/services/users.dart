import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Users with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');

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

  String get userId {
    return FirebaseAuth.instance.currentUser.uid;
  }
}

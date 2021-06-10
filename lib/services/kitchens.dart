import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Kitchens with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');

  String get userId {
    return FirebaseAuth.instance.currentUser.uid;
  }

  Future<Map> get sellerDetails async {
    final snapshot = await _mainCollection.doc(userId).get();
    return snapshot.data();
  }
}

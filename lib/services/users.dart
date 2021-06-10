import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Users with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');

  Map<String, dynamic> _userDetails = {
    'username': '',
    'email': '',
    'address': '',
    'phone': '',
    'isSeller': false,
    'hasOrdere': false,
    'kitchenId': null
  };

  Map<String, dynamic> get user {
    return {..._userDetails};
  }

  Future<Map> get setDbDetailsAndGet async {
    final snapshot = await _mainCollection.doc(userId).get();
    _userDetails = snapshot.data();
    return user;
  }

  String get userId {
    return FirebaseAuth.instance.currentUser.uid;
  }

  void setFields(String username, String phone, String address, bool isSeller,
      bool hasOrdered, String kitchenId, String email) {
    _userDetails['username'] = username;
    _userDetails['phone'] = phone;
    _userDetails['address'] = address;
    _userDetails['kitchenId'] = kitchenId;
    _userDetails['hasOrdered'] = hasOrdered;
    _userDetails['isSeller'] = isSeller;
    _userDetails['email'] = email;
  }

  void setDataFields(Map<String, dynamic> data) {
    _userDetails = data;
  }
}

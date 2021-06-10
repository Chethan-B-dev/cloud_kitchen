import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<String> get kitchenName async {
    final kitchenData =
        await _mainCollection.where('userId', isEqualTo: userId).get();
    return (kitchenData.docs[0].data() as Map<String, dynamic>)['kname'];
  }

  // TODO - add background color image to circular avatar

  Future<String> get kitchenId async {
    final kitchenData =
        await _mainCollection.where('userId', isEqualTo: userId).get();
    return (kitchenData.docs[0].data() as Map<String, dynamic>)['kitchenId'];
  }

  Future addKitchen(String kname, bool isNonVeg, File image) async {
    try {
      Map<String, dynamic> userDetails = await sellerDetails;

      final ref =
          FirebaseStorage.instance.ref('kitchens').child("$userId" + ".jpg");
      await ref.putFile(image);

      final imageUrl = await ref.getDownloadURL();

      DocumentReference document = await _mainCollection.add(
        {
          'kname': kname,
          'userId': userId,
          'username': userDetails['username'],
          'email': userDetails['email'],
          'phone': userDetails['phone'],
          'address': userDetails['address'],
          'isVeg': !isNonVeg,
          'rating': 0.0,
          'imageUrl': imageUrl,
        },
      );

      await _secCollection.doc(userId).update(
        {
          'kitchenId': document.id,
          'isSeller': true,
        },
      );
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

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class Kitchens with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('kitchens');
  final CollectionReference _secCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('foods');

  String get userId {
    return _auth.currentUser.uid;
  }

  Future<Map<String, dynamic>> get sellerDetails async {
    try {
      final snapshot = await _secCollection.doc(userId).get();
      return snapshot.data();
    } catch (err) {
      print(err.toString());
      throw (err.toString());
    }
  }

  Future<bool> isSeller() async {
    try {
      final data = await sellerDetails;
      return data['isSeller'];
    } catch (err) {
      print(err.toString());
      throw (err.toString());
    }
  }

  Future<String> get kitchenName async {
    try {
      final kitchenData =
          await _mainCollection.where('userId', isEqualTo: userId).get();
      return (kitchenData.docs[0].data() as Map<String, dynamic>)['kname'];
    } catch (err) {
      print(err.toString());
      throw (err.toString());
    }
  }

  Future<String> kitchenNameFromId(String kitchenId) async {
    try {
      final kitchenData = await _mainCollection.doc(kitchenId).get();
      return (kitchenData.data() as Map<String, dynamic>)['kname'];
    } catch (err) {
      print(err.toString());
      throw (err.toString());
    }
  }

  Future<String> get kitchenId async {
    try {
      final kitchenData = await _secCollection.doc(userId).get();
      return (kitchenData.data() as Map<String, dynamic>)['kitchenId'];
    } catch (err) {
      print(err.toString());
      throw (err.toString());
    }
  }

  Future addKitchen(String kname, bool isNonVeg, File image) async {
    try {
      Map<String, dynamic> userDetails = await sellerDetails;

      String userid = userId;

      final ref =
          FirebaseStorage.instance.ref().child("kitchens/$userid" + ".jpg");
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
          'createdAt': DateTime.now().toIso8601String(),
          'noOfRating': 0.0,
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

  Future<Stream<QuerySnapshot>> get foodItems async {
    try {
      final kitchenid = await kitchenId;
      return _foodCollection.doc(kitchenid).collection('items').snapshots();
    } catch (err) {
      throw (err.toString());
    }
  }

  Stream<QuerySnapshot> kitchenFoods(String kitchenId) {
    try {
      return _foodCollection.doc(kitchenId).collection('items').snapshots();
    } catch (err) {
      throw (err.toString());
    }
  }

  Stream<QuerySnapshot> get newKitchens {
    try {
      return _mainCollection.orderBy('createdAt', descending: true).snapshots();
    } catch (err) {
      throw (err.toString());
    }
  }

  Stream<QuerySnapshot> get allKitchens {
    try {
      return _mainCollection.orderBy('rating', descending: true).snapshots();
    } catch (err) {
      throw (err.toString());
    }
  }

  Future deleteFood(String id) async {
    try {
      String kitchenid = await kitchenId;
      await _foodCollection.doc(kitchenid).collection('items').doc(id).delete();
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

  Future addFood(String fname, bool isNonVeg, File image, double price) async {
    try {
      String kitchenid = await kitchenId;

      DocumentReference document =
          await _foodCollection.doc(kitchenid).collection('items').add(
        {
          'name': fname,
          'price': price.abs(),
          'imageUrl': '',
          'createdAt': DateTime.now().toIso8601String(),
          'isVeg': !isNonVeg,
        },
      );

      final ref =
          FirebaseStorage.instance.ref().child("foods/${document.id}" + ".jpg");
      await ref.putFile(image);

      final imageUrl = await ref.getDownloadURL();

      await _foodCollection
          .doc(kitchenid)
          .collection('items')
          .doc(document.id)
          .update(
        {
          'imageUrl': imageUrl,
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
//food--------------------->id (i.e kitchenid*)---------------->[items] {id,name,price,image,isVeg}

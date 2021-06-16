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

  Future<Map<String, dynamic>> get kitchenDetails async {
    try {
      final snapshot = await _mainCollection.doc(await kitchenId).get();
      return snapshot.data();
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

  Stream<DocumentSnapshot> get sellerDetailsStream {
    try {
      return _secCollection.doc(userId).snapshots();
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

  Future<bool> isSeller() async {
    try {
      final data = await sellerDetails;
      return data['isSeller'];
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

  Future<String> get kitchenName async {
    try {
      final kitchenData =
          await _mainCollection.where('userId', isEqualTo: userId).get();
      return (kitchenData.docs[0].data() as Map<String, dynamic>)['kname'];
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

  Future<String> kitchenNameFromId(String kitchenId) async {
    try {
      final kitchenData = await _mainCollection.doc(kitchenId).get();
      return (kitchenData.data() as Map<String, dynamic>)['kname'];
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

  Future<String> foodNameFromId(String foodId) async {
    try {
      final foodData = await _foodCollection
          .doc(await kitchenId)
          .collection('items')
          .doc(foodId)
          .get();
      return (foodData.data() as Map<String, dynamic>)['name'];
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

  Future<String> get kitchenId async {
    try {
      final kitchenData = await _secCollection.doc(userId).get();
      return (kitchenData.data() as Map<String, dynamic>)['kitchenId'];
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

  List<String> setSearchParam(String kname) {
    List<String> nameSearchList = [];
    List<String> nameWords = kname.split(' ');
    nameWords.add(kname);
    String temp = "";
    for (int j = 0; j < nameWords.length; j++) {
      for (int i = 0; i < nameWords[j].length; i++) {
        temp = temp + nameWords[j][i].toLowerCase();
        nameSearchList.add(temp);
      }
      temp = "";
    }

    return nameSearchList;
  }

  Future editKitchen(
    String kname,
    bool isNonVeg,
    File image,
    String existingUrl,
  ) async {
    try {
      String userid = userId;
      await FirebaseStorage.instance.refFromURL(existingUrl).delete();

      final ref =
          FirebaseStorage.instance.ref().child("kitchens/$userid" + ".jpg");
      await ref.putFile(image);

      final imageUrl = await ref.getDownloadURL();

      await _mainCollection.doc(await kitchenId).update({
        'kname': kname,
        'searchParams': setSearchParam(kname),
        'imageUrl': imageUrl,
        'isVeg': !isNonVeg,
      });
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
          'searchParams': setSearchParam(kname),
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

  Stream<QuerySnapshot> kitchenFoods(String kitchenId) {
    try {
      return _foodCollection.doc(kitchenId).collection('items').snapshots();
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

  Stream<QuerySnapshot> get newKitchens {
    try {
      return _mainCollection
          .where('userId', isNotEqualTo: userId)
          .orderBy('userId')
          .orderBy('createdAt', descending: true)
          .snapshots();
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

  Stream<QuerySnapshot> searchKitchen(String query) {
    try {
      return _mainCollection
          .where('userId', isNotEqualTo: userId)
          .where('searchParams', arrayContains: query)
          .snapshots();
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

  Stream<QuerySnapshot> get allKitchens {
    try {
      return _mainCollection
          .where('userId', isNotEqualTo: userId)
          .orderBy('userId')
          .orderBy('rating', descending: true)
          .snapshots();
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

  Future deleteKitchen() async {
    try {
      await _mainCollection.doc(await kitchenId).delete();
      await _foodCollection.doc(await kitchenId).delete();
      await _secCollection.doc(userId).update({
        'isSeller': false,
        'kitchenId': null,
      });
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

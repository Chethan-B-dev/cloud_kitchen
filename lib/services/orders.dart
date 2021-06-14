import 'dart:convert';
import 'package:cloud_kitchen/services/cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Orders with ChangeNotifier {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');
  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference _kitchenCollection =
      FirebaseFirestore.instance.collection('kitchens');

  Future<String> get userName async {
    try {
      final snapshot = await _userCollection.doc(userId).get();
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
      final snapshot = await _userCollection.doc(userId).get();
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

  String get userId {
    return FirebaseAuth.instance.currentUser.uid;
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

  Future<Map<String, dynamic>> get sellerDetails async {
    try {
      final snapshot = await _userCollection.doc(userId).get();
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

  Future<String> get kitchenName async {
    try {
      final kitchenData =
          await _kitchenCollection.where('userId', isEqualTo: userId).get();
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
      final kitchenData = await _kitchenCollection.doc(kitchenId).get();
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

  Future<String> get kitchenId async {
    try {
      final kitchenData = await _userCollection.doc(userId).get();
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

  Future<void> updateOrderStatus(
    int value,
    String userId,
    String orderId,
    BuildContext context,
  ) async {
    try {
      final doc = await _userCollection.doc(userId).get();
      final orderData = json
          .decode((doc.data() as Map<String, dynamic>)['orderStatus']) as Map;
      await doc.reference.update({
        'orderStatus': json.encode({
          orderData.keys.toList()[0]: value.toString(),
        })
      });

      if (value == 3) {
        await Provider.of<Cart>(context, listen: false).deleteOrder(
          orderId,
          userId,
          false,
        );
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

  Future<Stream<QuerySnapshot>> get orderList async {
    try {
      return _orderCollection
          .doc(await kitchenId)
          .collection('orders')
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
}

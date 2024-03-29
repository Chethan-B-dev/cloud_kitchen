import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_kitchen/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;

  UserModel _userFromFirebaseUser(User user) {
    return user != null ? UserModel(id: user.uid) : null;
  }

  Stream<UserModel> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user;

      prefs = await SharedPreferences.getInstance();
      prefs.remove('email');
      prefs.setString('email', email);
      prefs.remove('userId');
      prefs.setString('userId', user.uid);

      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw ('The account already exists for that email.');
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
      }
      throw (message);
    } catch (error) {
      throw ('Could not authenticate you. Please try again later.');
    }
  }

  Future registerWithEmailAndPassword(String email, String password,
      String username, String phone, String address) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'email': email,
          'username': username,
          'phone': phone,
          'address': address,
          'isSeller': false,
          'hasOrdered': false,
          'kitchenId': null,
          'orderStatus': null,
        },
      );

      prefs = await SharedPreferences.getInstance();
      prefs.remove('email');
      prefs.setString('email', email);
      prefs.remove('userId');
      prefs.setString('userId', user.uid);
      prefs.remove('username');
      prefs.setString('username', username);

      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw ('The account already exists for that email.');
      }
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

  Future<void> signOut() async {
    try {
      prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return await _auth.signOut();
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

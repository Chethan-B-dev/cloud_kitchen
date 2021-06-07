import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  static final instance = Auth._();
  Auth._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool get isSignedIn => _auth.currentUser != null;

  Stream<User> authStateChange() => _auth.authStateChanges();

  Future<void> signOut() => _auth.signOut();
}

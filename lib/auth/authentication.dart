import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthentication {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  String userId();
  Future<void > signOut();
}

class AuthenticateUser implements BaseAuthentication {
  
  // uid once logged in
  String _userId = "";

  //------------------------------------------------------
  // Current user, or `null` if there is none.
  //------------------------------------------------------
  Future<String> currentUser() async {

    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    // Save for use in userId().
    _userId = (user == null) ? null : user.uid;

    // Return unique user id.
    return _userId;
  }

  //------------------------------------------------------
  // Signin user with email/password.
  //------------------------------------------------------
  Future<String> signInWithEmailAndPassword(String email, String password) async {

    FirebaseUser user =
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    // Save for use in userId().
    _userId = user.uid;

    // Return unique user id.
    return user.uid;
  }

  //------------------------------------------------------
  // Create user with email/password.
  //------------------------------------------------------
  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    
    FirebaseUser user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Save for use in userId().
    _userId = user.uid;

    // Return unique user id.
    return user.uid;
  }

  //------------------------------------------------------
  // Return the Firebase current user id (uid)
  //------------------------------------------------------
  String userId()
  {
    return _userId;
  }

  //------------------------------------------------------
  // Logout user.
  //------------------------------------------------------
  Future<void > signOut() async {
    return FirebaseAuth.instance.signOut();
  }

}

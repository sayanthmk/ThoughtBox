import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth firebaseAuth;

  FirebaseService({
    required this.firebaseAuth,
  });

//------------------SignIn --Email & Password ------------------------------------//

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    final UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    return userCredential.user;
  }

//------------------SignUp --Email & Password ------------------------------------//

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign-up: $e');
      }

      return null;
    }
  }

//------------------SignOut ------------------------------------//

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

//------------------SignUp --Get the User ------------------------------------//

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
}

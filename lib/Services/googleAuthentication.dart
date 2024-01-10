import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _singleton = new AuthService._internal();
  AuthService._internal();
  static AuthService get instance => _singleton;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String?imageUrl;
  String?userName;

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user!;

    if (user != null) {
      // Checking if email and name is null
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);

      imageUrl = user.photoURL!;
      userName = user.displayName!;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);
      //signin through google and set name,email and profile image on firebase
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'user': userName,
        'profileimg': user.photoURL,
      });

      print('signInWithGoogle succeeded: $user');

      return '${user.uid}';
    }
    return Exception().toString();
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
  }
}

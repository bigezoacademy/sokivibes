import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1000550306677-o616hchvjkq2ft0vj4tvu3pn11rt3kcd.apps.googleusercontent.com',
  );

  Stream<User?> get userChanges => _auth.userChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<User?> signInWithGoogle() async {
    try {
      print('Starting Google sign-in...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled by user.');
        return null;
      }
      print('Google user: \\${googleUser.email}, id: \\${googleUser.id}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          'Google auth: accessToken=\\${googleAuth.accessToken}, idToken=\\${googleAuth.idToken}');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Signing in with Firebase credential...');
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      print('Firebase user: \\${user?.uid}, email: \\${user?.email}');
      if (user == null) {
        print('No Firebase user after sign-in.');
        return null;
      }
      if (user.email == null) {
        print('Firebase user email is null! Cannot continue.');
        await _auth.signOut();
        return null;
      }
      final firestore = FirebaseFirestore.instance;
      print('Checking Firestore for user with email: \\${user.email}');
      final query = await firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      print('Firestore query docs: \\${query.docs.length}');
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        print('Firestore user doc data: \\${data.toString()}');
        final userRef = firestore.collection('users').doc(user.uid);
        final mergedData = {
          ...data,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'email': user.email,
          'role': (data['role'] ??
              (AppConstants.adminEmails.contains(user.email)
                  ? 'admin'
                  : 'user')),
          'createdAt': (data['createdAt'] ?? FieldValue.serverTimestamp()),
        };
        print('Merged user data to set: \\${mergedData.toString()}');
        await userRef.set(mergedData, SetOptions(merge: true));
        for (final d in query.docs) {
          if (d.id != user.uid) {
            print('Deleting duplicate Firestore user doc: \\${d.id}');
            await firestore.collection('users').doc(d.id).delete();
          }
        }
        print('Returning user after Firestore update.');
        return user;
      } else {
        print('No Firestore user found for this email. Creating new user doc.');
        final userRef = firestore.collection('users').doc(user.uid);
        final newUserData = {
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'email': user.email,
          'role': (AppConstants.adminEmails.contains(user.email)
              ? 'admin'
              : 'user'),
          'createdAt': FieldValue.serverTimestamp(),
        };
        await userRef.set(newUserData);
        print('New Firestore user doc created. Returning user.');
        return user;
      }
    } catch (e, stack) {
      print('signInWithGoogle error: \\${e.toString()}');
      print('Stack trace: \\${stack.toString()}');
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;
}

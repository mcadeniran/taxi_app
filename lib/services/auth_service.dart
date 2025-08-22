import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_app/models/profile.dart';

// ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up new user and create profile
  Future<Profile?> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      final profile = Profile(
        id: uid,
        email: email,
        username: username,
        role: role,
        drives: [],
        rides: [],
        token: '',
        personal: Personal(
          firstName: '',
          lastName: '',
          photoUrl: '',
          rating: 0,
          phone: '',
        ),
        vehicle: Vehicle(
          numberPlate: '',
          colour: '',
          licence: '',
          model: '',
          carImage: '',
        ),
        account: Account(
          isOnline: true,
          isProfileCompleted: false,
          isApproved: role == 'driver' ? false : true,
          createdAt: DateTime.now(),
        ),
      );

      // Save profile to Firestore
      await _firestore.collection('profiles').doc(uid).set(profile.toMap());

      return profile;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists with that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('This sign-up method is disabled.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('The supplied credential is invalid or expired.');
      } else {
        throw Exception('Signup failed. Please try again.');
      }
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Login with email & password
  Future<Profile?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await getProfile(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else if (e.code == 'user-not-found') {
        throw Exception('No account found with that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current logged-in user's profile
  Future<Profile?> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getProfile(user.uid);
  }

  /// Fetch profile from Firestore by user ID
  Future<Profile?> getProfile(String uid) async {
    final doc = await _firestore.collection('profiles').doc(uid).get();
    if (!doc.exists) return null;
    return Profile.fromFirestore(doc);
  }

  /// Stream profile for realtime updates
  Stream<Profile?> streamProfile(String uid) {
    return _firestore
        .collection('profiles')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? Profile.fromFirestore(doc) : null);
  }
  // Future<void> resetPassword({required String email}) async {
  //   await firebaseAuth.sendPasswordResetEmail(email: email);
  // }

  // Future<void> updateUsername({required String username}) async {
  //   await currentUser!.updateDisplayName(username);

  //   // Also update in Firestore
  //   await firestore.collection('profiles').doc(currentUser!.uid).update({
  //     'username': username,
  //   });
  // }

  // Future<void> deleteAccount({
  //   required String email,
  //   required String password,
  // }) async {
  //   AuthCredential credential = EmailAuthProvider.credential(
  //     email: email,
  //     password: password,
  //   );

  //   // Reauthenticate
  //   await currentUser!.reauthenticateWithCredential(credential);

  //   // Delete Firestore profile
  //   await firestore.collection('profiles').doc(currentUser!.uid).delete();

  //   // Delete Firebase Auth account
  //   await currentUser!.delete();

  //   // Sign out
  //   await firebaseAuth.signOut();
  // }

  // Future<void> resetPasswordFromCurrentPassword({
  //   required String newPassword,
  //   required String currentPassword,
  //   required String email,
  // }) async {
  //   AuthCredential credential = EmailAuthProvider.credential(
  //     email: email,
  //     password: currentPassword,
  //   );
  //   await currentUser!.reauthenticateWithCredential(credential);
  //   await currentUser!.updatePassword(newPassword);
  // }
}

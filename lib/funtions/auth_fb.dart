import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/screens/loginpage.dart';

class AuthMethods {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (!isValidEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address.')),
        );
        return null;
      }

      if (!isValidPassword(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password must be at least 6 characters long.')),
        );
        return null;
      }

      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!result.user!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your email address.')),
        );
        return null;
      }

      return result;
    } catch (e) {
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No account found with this email')),
      );
      return null;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username, // Added username parameter
    required BuildContext context,
    required String phoneNumber,
  }) async {
    try {
      // Validate email
      if (!isValidEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address.')),
        );
        return null;
      }

      if (!isValidPassword(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password must be at least 6 characters long.')),
        );
        return null;
      }

      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await sendEmailVerification(result.user!);

      // Save user data in Firestore with email as document ID (title)
      await saveUserData(
        uid: result.user!.uid,
        email: email,
        username: username, // Pass the username here
        phoneNumber: "",
        verified: false,
        profileImageUrl: '',
      );

      return result;
    } catch (e) {
      print('Error during sign-up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up failed. Please try again.')),
      );
      return null;
    }
  }

  Future<void> resetPassword(
      {required String email, required BuildContext context}) async {
    // Validate email
    if (email.isEmpty || !isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email.')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      print('Error sending password reset email: $e');
    }
  }

  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
      print('Verification email sent to ${user.email}');
      user.reload();
      if (user.emailVerified) {
        await updateEmailVerifiedStatus();
      }
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  Future<void> updateEmailVerifiedStatus() async {
    User? user = _firebaseAuth.currentUser;

    if (user != null && user.emailVerified) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'verified': true,
        });
        print('User verification status updated.');
      } catch (e) {
        print('Error updating verification status: $e');
      }
    }
  }

  Future<void> saveUserData({
    required String uid,
    required String email,
    required String username, // Added username field
    required String phoneNumber,
    required bool verified,
    required String profileImageUrl,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email) // Using email as the document ID (title)
          .set({
        'uid': uid,
        'email': email,
        'username': username, // Store the username
        'phoneNumber': phoneNumber,
        'verified': verified,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("User data saved successfully.");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      bool? confirmSignOut = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Sign-Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Sign Out'),
              ),
            ],
          );
        },
      );

      if (confirmSignOut == true) {
        await _firebaseAuth.signOut();
        await _googleSignIn.signOut();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('userId');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully signed out.')),
        );
      } else {
        // If user canceled, show a message (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign out canceled.')),
        );
      }
    } catch (e) {
      print('Error during sign-out: $e');
      showSnackBar(context, 'Error during sign-out.');
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        showSnackBar(context, 'Google sign-in cancelled.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/TodoScreen');
        showSnackBar(context, 'Successfully signed in with Google!');
      }
    } catch (e) {
      print('Error during Google login: $e');
      showSnackBar(context, 'Google login failed. Error: $e');
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

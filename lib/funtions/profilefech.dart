 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final String email = FirebaseAuth.instance.currentUser?.email ?? '';
  final String? username = FirebaseAuth.instance.currentUser?.displayName;
  final String? photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    if (userId.isNotEmpty) {
      try {
    
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email) 
            .get();

        if (userDoc.exists) {
          print("User Document: ${userDoc.data()}");

          String profileImageUrl = userDoc['profileImageUrl'] ??
              ''; 
          String username =
              userDoc['username'] ?? ''; 
          String email = userDoc['email'] ?? '';

          return {
            'profileImageUrl': profileImageUrl,
            'username': username,
            'email': email,
          };
        } else {
          print('No document found for user: $userId');
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
    return null;
  }

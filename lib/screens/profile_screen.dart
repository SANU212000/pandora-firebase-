import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/funtions/auth_fb.dart';
import 'package:todo_list/funtions/constants.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No profile found.'));
        }

        Map<String, dynamic> userProfile = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: userProfile['profileImageUrl'] != ''
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                NetworkImage(userProfile['profileImageUrl']),
                          )
                        : CircleAvatar(
                            radius: 60,
                            child: Icon(Icons.person,
                                size: 50, color: Colors.white),
                            backgroundColor: kPrimaryColor,
                          ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Username: ${userProfile['username']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${userProfile['email']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthMethods().signOut(context);
                    },
                    child: Text('logout'),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
final String email = FirebaseAuth.instance.currentUser?.email ?? '';
final String? username = FirebaseAuth.instance.currentUser?.displayName;
final String? photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

Future<Map<String, dynamic>?> _fetchUserProfile() async {
  if (userId.isNotEmpty) {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        print("User Document: ${userDoc.data()}");

        String profileImageUrl = userDoc['profileImageUrl'] ?? '';
        String username = userDoc['username'] ?? '';
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

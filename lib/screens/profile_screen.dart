import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/funtions/auth_fb.dart';
import 'package:todo_list/funtions/awsserives.dart';
import 'package:todo_list/funtions/constants.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final String email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();

        if (userDoc.exists) {
          setState(() {
            profileImageUrl = userDoc['imageurl'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String email = FirebaseAuth.instance.currentUser?.email ?? '';

      if (email.isNotEmpty) {
        String? uploadedUrl = await AWSS3Service().uploadFile(file, email);
        if (uploadedUrl != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(email)
              .update({'imageurl': uploadedUrl});
          setState(() {
            profileImageUrl = uploadedUrl;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : null,
                    child: profileImageUrl == null || profileImageUrl!.isEmpty
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                    backgroundColor: kPrimaryColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Email: ${FirebaseAuth.instance.currentUser?.email ?? ''}',
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
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
  }
}

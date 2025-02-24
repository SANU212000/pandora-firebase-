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
  String userName = "username not found";
  bool isUploading = false;

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
            userName = userDoc['username'] ?? 'User';
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
        setState(() => isUploading = true);

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

        setState(() => isUploading = false);
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    String email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .update({'imageurl': ''});
      setState(() {
        profileImageUrl = '';
      });
    }
  }

  Future<void> _editUserName() async {
    TextEditingController _nameController =
        TextEditingController(text: userName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Name"),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String newName = _nameController.text.trim();
              if (newName.isNotEmpty) {
                String email = FirebaseAuth.instance.currentUser?.email ?? '';
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(email)
                    .update({'username': newName});
                setState(() => userName = newName);
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthMethods().signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editUserName,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : null,
                    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                    backgroundColor: kPrimaryColor,
                  ),
                  if (isUploading)
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                userName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                FirebaseAuth.instance.currentUser?.email ?? '',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadImage,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Change Photo"),
                  ),
                  SizedBox(width: 10),
                  if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _deleteProfileImage,
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text("Remove"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

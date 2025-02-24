import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AWSS3Service {
  final String baseApiUrl =
      "https://filesapisample.stackmod.info/api/presigned-url";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> uploadFile(File file, String userEmail) async {
    try {
      if (!file.existsSync()) {
        print("File does not exist: ${file.path}");
        return null;
      }

      print("Attempting to upload image: ${file.uri.pathSegments.last}");

      final response = await http.post(
        Uri.parse(baseApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"fileName": file.uri.pathSegments.last}),
      );

      if (response.statusCode != 200) {
        print("Failed to get presigned URL. Response: ${response.body}");
        return null;
      }

      final data = jsonDecode(response.body);
      if (!data.containsKey("url") || !data.containsKey("uploadedFilePath")) {
        print("Invalid response: Missing 'url' or 'uploadedFilePath'");
        return null;
      }

      final String uploadUrl = data["url"];
      final String fileUrl = data["uploadedFilePath"];
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': mimeType},
        body: await file.readAsBytes(),
      );

      if (uploadResponse.statusCode == 200) {
        print("File successfully uploaded: $fileUrl");
        await updateProfilePicture(userEmail, fileUrl);
        return fileUrl;
      } else {
        print("File upload failed. Response: ${uploadResponse.body}");
        return null;
      }
    } catch (e, stackTrace) {
      print("Upload error: $e");
      print("Stack trace: $stackTrace");
      return null;
    }
  }

  Future<void> updateProfilePicture(String userEmail, String imageUrl) async {
    if (userEmail.isEmpty || imageUrl.isEmpty) {
      print("Error: User email or image URL is empty");
      return;
    }

    try {
      await _firestore.collection('users').doc(userEmail).update({
        'profileImageUrl': imageUrl,
      });
      print("Profile picture updated successfully");
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> removeProfilePicture(String userEmail) async {
    if (userEmail.isEmpty) {
      print("Error: User email is empty");
      return;
    }

    try {
      await _firestore.collection('users').doc(userEmail).update({
        'imageurl': FieldValue.delete(),
      });
      print('Profile picture removed successfully');
    } catch (e) {
      print('Error removing profile picture: $e');
    }
  }

  Future<String?> fetchProfilePicture(String userEmail) async {
    if (userEmail.isEmpty) {
      print("Error: User email is empty");
      return null;
    }

    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userEmail).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['profileImageUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching profile picture: $e');
      return null;
    }
  }
}

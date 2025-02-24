// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:mime/mime.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AWSS3Service {
//   final String baseApiUrl =
//       "https://filesapisample.stackmod.info/api/presigned-url";

//   Future<String?> uploadFile(File file, String noteId) async {
//     try {
//       if (!file.existsSync()) {
//         print(" File does not exist: ${file.path}");
//         return null;
//       }

//       print(" Attempting to upload image: ${file.uri.pathSegments.last}");

//       final response = await http.post(
//         Uri.parse(baseApiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(
//             {"noteId": noteId, "fileName": file.uri.pathSegments.last}),
//       );

//       print(" Presigned URL Response Status: ${response.statusCode}");
//       print(" Presigned URL Response Body: ${response.body}");

//       if (response.statusCode != 200) {
//         print(" Failed to get presigned URL. Response: ${response.body}");
//         return null;
//       }

//       final data = jsonDecode(response.body);
//       if (!data.containsKey("url") || !data.containsKey("uploadedFilePath")) {
//         print(" Invalid response: Missing 'url' or 'uploadedFilePath'");
//         return null;
//       }

//       final String uploadUrl = data["url"];
//       final String fileUrl = data["uploadedFilePath"];

//       final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
//       print(" Uploading file with MIME type: $mimeType");

//       final uploadResponse = await http.put(
//         Uri.parse(uploadUrl),
//         headers: {
//           'Content-Type': mimeType,
//         },
//         body: await file.readAsBytes(),
//       );

//       print(" S3 Upload Response Status: ${uploadResponse.statusCode}");
//       print(" S3 Upload Response Body: ${uploadResponse.body}");

//       if (uploadResponse.statusCode == 200) {
//         print(" File successfully uploaded: $fileUrl");

//         await saveImageToFirestore(fileUrl, noteId);
//         return fileUrl;
//       } else {
//         print(" File upload failed. Response: ${uploadResponse.body}");
//         return null;
//       }
//     } catch (e, stackTrace) {
//       print(" Upload error: $e");
//       print("Stack trace: $stackTrace");
//       return null;
//     }
//   }

//   Future<void> saveImageToFirestore(String imageUrl, String noteId) async {
//     try {
//       if (imageUrl.isEmpty || noteId.isEmpty) {
//         throw Exception('Invalid imageUrl or noteId');
//       }

//       CollectionReference images =
//           FirebaseFirestore.instance.collection('images');

//       int retryCount = 0;
//       const maxRetries = 3;

//       while (retryCount < maxRetries) {
//         try {
//           await images.add({
//             'noteId': noteId,
//             'imageUrl': imageUrl,
//             'timestamp': FieldValue.serverTimestamp(),
//             'createdAt': DateTime.now().toIso8601String(),
//           });

//           print(" Image URL saved to Firestore: $imageUrl");
//           return;
//         } catch (e) {
//           retryCount++;
//           if (retryCount == maxRetries) {
//             rethrow;
//           }
//           await Future.delayed(Duration(seconds: retryCount));
//         }
//       }
//     } catch (e) {
//       print(" Error saving image URL: $e");
//       throw Exception('Failed to save image to Firestore: $e');
//     }
//   }

//   Future<List<String>> fetchImages(String noteId,
//       {int limit = 20, DocumentSnapshot? lastDocument}) async {
//     try {
//       if (noteId.isEmpty) {
//         throw Exception('Invalid noteId: $noteId is empty');
//       }

//       print(' Fetching images for noteId: $noteId, limit: $limit');

//       Query query = FirebaseFirestore.instance
//           .collection('images')
//           .where('noteId', isEqualTo: noteId)
//           .orderBy('timestamp', descending: true);

//       if (lastDocument != null) {
//         query = query.startAfterDocument(lastDocument);
//         print(' Starting after document: ${lastDocument.id}');
//       }

//       query = query.limit(limit);

//       final QuerySnapshot<Object?> snapshot = await query.get();

//       print(" Firestore Docs Count: ${snapshot.docs.length}");

//       if (snapshot.docs.isEmpty) {
//         print(' No images found for noteId: $noteId');
//         return [];
//       }

//       for (var doc in snapshot.docs) {
//         print(" Document ID: ${doc.id}");
//         print(" Document Data: ${doc.data()}");
//       }

//       final List<String> urls = snapshot.docs
//           .map((doc) {
//             final data = doc.data() as Map<String, dynamic>?;
//             final imageUrl = data?['imageUrl'] as String?;
//             return imageUrl?.isNotEmpty == true ? imageUrl : null;
//           })
//           .where((url) => url != null)
//           .cast<String>()
//           .toList();

//       print(" Successfully fetched ${urls.length} images for noteId: $noteId");

//       return urls;
//     } catch (e, stackTrace) {
//       print(" Error fetching images: $e");
//       print("Stack trace: $stackTrace");
//       return [];
//     }
//   }

//   Future<bool> deleteImage(String imageUrl, String noteId) async {
//     try {
//       final QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('images')
//           .where('noteId', isEqualTo: noteId)
//           .where('imageUrl', isEqualTo: imageUrl)
//           .get();

//       if (snapshot.docs.isEmpty) {
//         print(" No matching image found to delete");
//         return false;
//       }

//       for (var doc in snapshot.docs) {
//         await doc.reference.delete();
//       }

//       print(" Successfully deleted image from Firestore");
//       return true;
//     } catch (e) {
//       print(" Error deleting image: $e");
//       return false;
//     }
//   }
// }
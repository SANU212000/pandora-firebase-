import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:todo_list/funtions/controller.dart';
import 'package:todo_list/funtions/constants.dart';
import 'package:todo_list/funtions/navigation.dart';
import 'firebase_options.dart'; // Ensure this is imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register controllers with GetX
  Get.put(TodoController());

  // Initialize theme changer
  final themeChanger = Get.put(ThemeChanger());
  await themeChanger.loadtheme();

  runApp(const TodoApp());
}

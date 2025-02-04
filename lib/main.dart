import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:todo_list/funtions/controller.dart';
import 'package:todo_list/funtions/navigation.dart';
import 'package:todo_list/screens/screen1.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(TodoController());

  final themeChanger = Get.put(ThemeChanger());
  await themeChanger.loadtheme();

  runApp(TodoApp());
}
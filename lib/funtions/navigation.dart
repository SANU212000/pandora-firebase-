import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/screens/addnewusers.dart';
import 'package:todo_list/screens/loginpage.dart';
import 'package:todo_list/screens/screen1.dart';
import 'package:todo_list/screens/intro.dart';
import 'package:todo_list/funtions/controller.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themechanger = Get.put(ThemeChanger());

    return Obx(() => GetMaterialApp(
          title: 'Todo App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themechanger.themeMode.value,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const IntroScreen(),
            ),
            GetPage(
              name: '/userScreen',
              page: () => const LoginScreen(),
            ),
            GetPage(
              name: '/home',
              page: () => TodoScreen(),
            ),
            GetPage(
              name: '/TodoScreen',
              page: () => TodoScreen(),
              binding: BindingsBuilder(() {
                Get.put(TodoController());
              }),
            ),
            GetPage(
              name: '/register', // New route for Register Screen
              page: () => AddNewUser(), // Navigate to RegisterScreen
            ),
          ],
        ));
  }
}

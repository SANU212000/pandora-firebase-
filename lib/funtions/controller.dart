import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var todos = <Todo>[].obs;
  var isLoading = false.obs;

  Future<void> fetchTodos(String userEmail) async {
    isLoading(true);
    try {
      if (userEmail.isEmpty) {
        print("Error: User email is empty");
        return;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('todos')
          .get();

      todos.value =
          querySnapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching todos: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addTodo(String userEmail, String title) async {
    if (userEmail.isEmpty) {
      print("Error: User email is empty");
      return;
    }

    try {
      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        isCompleted: false,
        userId: userEmail,
        task: '',
      );

      await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('todos')
          .doc(newTodo.id)
          .set(newTodo.toJson());

      fetchTodos(userEmail);
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  /// Update a todo
  Future<void> updateTodo({
    required String userEmail,
    required String id,
    required String newTitle,
  }) async {
    if (userEmail.isEmpty) {
      print("Error: User email is empty");
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('todos')
          .doc(id)
          .update({'title': newTitle});

      fetchTodos(userEmail);
      print('Todo updated successfully!');
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  Future<void> removeTodo(String userEmail, String id) async {
    try {
      if (userEmail.isEmpty) {
        print("Error: User email is empty");
        return;
      }

      await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('todos')
          .doc(id)
          .delete();

      fetchTodos(userEmail);
      print('Todo deleted successfully');
    } catch (e) {
      print('Error removing todo: $e');
    }
  }

  Future<void> toggleTodoStatus(String userEmail, String id) async {
    if (userEmail.isEmpty) {
      print("Error: User email is empty");
      return;
    }

    try {
      final todoDoc = await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('todos')
          .doc(id)
          .get();

      if (todoDoc.exists) {
        final currentStatus = todoDoc['isCompleted'] as bool;
        await _firestore
            .collection('users')
            .doc(userEmail)
            .collection('todos')
            .doc(id)
            .update({'isCompleted': !currentStatus});

        fetchTodos(userEmail);
      }
    } catch (e) {
      print('Error toggling todo status: $e');
    }
  }
}

enum ThemeOption { light, dark }

class ThemeChanger extends GetxController {
  var themeMode = ThemeMode.system.obs;

  void setTheme(ThemeOption themeOption) {
    switch (themeOption) {
      case ThemeOption.light:
        themeMode.value = ThemeMode.light;
        break;
      case ThemeOption.dark:
        themeMode.value = ThemeMode.dark;
        break;
    }
    savetheme();
  }

  void savetheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('themedata', themeMode.value.toString());
    print('Saved theme: ${themeMode.value}');
  }

  Future<void> loadtheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final savedtheme = pref.getString('themedata');
    if (savedtheme != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (element) => element.toString() == savedtheme,
        orElse: () => ThemeMode.system,
      );
    }
    print('Loaded theme: ${themeMode.value}');
  }
}

class UserController extends GetxController {
  var userId = ''.obs;
  var email = ''.obs;
  var username = ''.obs;
  var isLoggedIn = false.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
  
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
     
          username.value =
              userDoc['username'] ?? 'User'; 
          email.value = user.email ?? '';
          userId.value = user.uid;
          isLoggedIn.value = true;
        } else {
          // If user document doesn't exist, save new user data to Firestore
          username.value = 'User'; // Default username if not found
          email.value = user.email ?? '';
          userId.value = user.uid;

          // Save user details to Firestore
          await saveUserDetails(username.value, email.value, userId.value);
        }

        // Save user details locally
        _saveUserDetails(username.value, email.value, userId.value);

        // If TodoController is registered, fetch todos
        if (Get.isRegistered<TodoController>()) {
          Get.find<TodoController>().fetchTodos(email.value);
        }
      } catch (e) {
        print('Error fetching user details: $e');
      }
    } else {
      // If user is not logged in, load from local storage
      username.value = box.read('username') ?? 'Guest';
      email.value = box.read('email') ?? '';
      userId.value = box.read('userId') ?? '';
      isLoggedIn.value = userId.isNotEmpty;

      // If TodoController is registered, fetch todos
      if (Get.isRegistered<TodoController>()) {
        Get.find<TodoController>().fetchTodos(email.value);
      }
    }
  }

  Future<void> saveUserDetails(
      String username, String email, String userId) async {
    try {
      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
        'email': email,
      });
    } catch (e) {
      print('Error saving user details: $e');
    }
  }

  void _saveUserDetails(String name, String userEmail, String id) {
    // Save user details locally
    box.write('username', name);
    box.write('email', userEmail);
    box.write('userId', id);
  }

  /// Logout and clear stored data
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    userId.value = '';
    email.value = '';
    username.value = 'Guest';
    isLoggedIn.value = false;
    _clearUserDetails();
  }

  void _clearUserDetails() {
    box.remove('username');
    box.remove('email');
    box.remove('userId');
  }
}

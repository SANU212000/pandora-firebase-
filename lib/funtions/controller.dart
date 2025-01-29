import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userId = ''.obs; 
  var todos = <Todo>[].obs; 
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    isLoading(true);
    try {
      final userId = Get.find<UserController>().userId.value;
      print('Fetching todos for userId: $userId'); 

      final querySnapshot = await _firestore
          .collection('users') 
          .doc(userId) 
          .collection('todos') 
          .get(); 

      print('Documents fetched: ${querySnapshot.docs.length}'); 

      todos.value = querySnapshot.docs
          .map((doc) => Todo.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching todos: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final userId = Get.find<UserController>().userName.value;

      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        isCompleted: false,
        userId: userId,
        task: '',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(newTodo.id)
          .set(newTodo.toJson());

      fetchTodos();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(String id, {required String newTitle}) async {
    try {
      final todoDoc = _firestore.collection('todos').doc(id);
      await todoDoc.update({
        'title': newTitle,
      });
      fetchTodos();
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  Future<void> removeTodo(String id) async {
    try {
      await _firestore.collection('todos').doc(id).delete();
      fetchTodos();
    } catch (e) {
      print('Error removing todo: $e');
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      final todoDoc = _firestore.collection('todos').doc(id);
      final todo = await todoDoc.get();
      if (todo.exists) {
        final currentStatus = todo['isCompleted'] as bool;
        await todoDoc.update({'isCompleted': !currentStatus});
        fetchTodos();
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
  var userName = ''.obs;
  var userEmail = ''.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDetails();
  }

  // Fetch user details from Firebase or SharedPreferences
  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If user is logged in, get details from Firebase
      userId.value = user.uid;
      userName.value = user.displayName ?? 'User';
      userEmail.value = user.email ?? '';
      isLoggedIn.value = true;
    } else {
      // If no user is logged in, fetch details from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUserName = prefs.getString('userName') ?? 'Guest';
      userName.value = storedUserName;
      userId.value = ''; // No Firebase user
      isLoggedIn.value = false;
    }
  }

  // Log in user (in case Firebase Auth is not used)
  void loginUser(String name, String email) {
    isLoggedIn.value = true;
    userName.value = name;
    userEmail.value = email;
    _saveUserDetailsToLocalStorage(name);
  }

  // Log out user and clear data
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    userId.value = '';
    userName.value = 'Guest';
    userEmail.value = '';
    isLoggedIn.value = false;
    _clearUserDetailsFromLocalStorage();
  }

  // Save user details to SharedPreferences
  Future<void> _saveUserDetailsToLocalStorage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', name);
  }

  // Clear user details from SharedPreferences
  Future<void> _clearUserDetailsFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userName');
  }
}

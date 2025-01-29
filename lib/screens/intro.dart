import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/screens/loginpage.dart';
import 'package:todo_list/screens/screen1.dart';
import 'package:todo_list/funtions/constants.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    navigateAfterDelay(context);
  }

  Future<void> navigateAfterDelay(BuildContext context) async {
    final initialRoute = await determineInitialRoute();
    await Future.delayed(const Duration(seconds: 4));

    try {
      if (initialRoute == '/home') {
        Get.offAll(() => TodoScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    } catch (e, stackTrace) {
      print('Navigation error: $e\n$stackTrace');
    }
  }

  Future<String> determineInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null && refreshToken.isNotEmpty) {
      print('Refresh token retrieved: $refreshToken');
      return '/home';
    }

    print('No refresh token found.');
    return '/userScreen';
  }

  Future<void> fetchDataWithTokenInQuery(refreshToken) async {
    String token = refreshToken;

    final response = await http.get(
      Uri.parse(
          'https://api.example.com/protected-resource?access_token=$token'),
    );

    if (response.statusCode == 200) {
      print('Data: ${response.body}');
    } else {
      print('Failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 2.0),
              duration: const Duration(seconds: 3),
              curve: Curves.bounceOut,
              builder: (context, scaleValue, child) {
                return Transform.scale(
                  scale: scaleValue,
                  child: const Text(
                    "Pandora",
                    style: TextStyle(
                      fontFamily: "intro",
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 5),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, opacityValue, child) {
                return Opacity(
                  opacity: opacityValue,
                  child: const Text(
                    "stability for your time",
                    style: TextStyle(
                      fontFamily: "intro",
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: kPrimaryColor,
    );
  }
}


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:todo_list/screens/screen1.dart';

class OTPVerificationScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();

  final String contactInfo;
  final String email;
  final String fullName;
  final String phone;

  final String password;

  OTPVerificationScreen({
    super.key,
    required this.contactInfo,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.password,
  });

  Future<void> sendOTP(BuildContext context) async {
    try {
      final String otpSendURL =
          'https://sampleapi.stackmod.info/api/v1/auth/otp?email=${Uri.encodeComponent(email)}';
      final url = Uri.parse(otpSendURL);
      print(url);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseBody['message'] ?? 'OTP sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending OTP: $e')),
        );
      }
    }
  }

  Future<void> verifyOTP(BuildContext context) async {
    final otp = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text;

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      const String otpVerificationURL =
          'https://sampleapi.stackmod.info/api/v1/auth/otp';
      final url = Uri.parse(otpVerificationURL);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp, 'email': email}),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['verified'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP Verified Successfully!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseBody['message'] ?? 'Verification failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to verify OTP: ${response.statusCode}')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      if (context.mounted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => sendOTP(context));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 30,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'OTP Verification',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter the 4-digit code sent to $contactInfo',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _otpBox(context, _otpController1),
                        _otpBox(context, _otpController2),
                        _otpBox(context, _otpController3),
                        _otpBox(context, _otpController4),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          verifyOTP(context).then((_) {
                            registerUser(
                                context, fullName, email, password, phone);
                          });
                        }
                      },
                      child: const Text('Verify'),
                    ),
                    TextButton(
                      onPressed: () {
                        sendOTP(context);
                      },
                      child: const Text('Resend OTP'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpBox(BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: 50,
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        buildCounter: (BuildContext context,
                {int? currentLength, int? maxLength, bool? isFocused}) =>
            null,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          if (!RegExp(r'^[0-9]$').hasMatch(value)) {
            return '';
          }
          return null;
        },
      ),
    );
  }
}

Future<void> registerUser(BuildContext context, String fullName, String email,
    String password, String phone) async {
  const String apiUrl = 'https://sampleapi.stackmod.info/api/v1/auth/signup';

  try {
    final Map<String, String> requestBody = {
      'fullname': fullName,
      'email': email,
      'password': password,
      'phone': phone,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful.')),
      );
    } else if (response.statusCode == 400) {
      final errorMessage = json.decode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup Failed: $errorMessage')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signup Failed: Unexpected error (Status code: ${response.statusCode})',
          ),
        ),
      );
    }
  } catch (e) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('An error occurred: $e')),
    // );
  }
}

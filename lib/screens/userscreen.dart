// import 'package:flutter/material.dart';
// import 'package:todo_list/funtions/databasehelper.dart';

// class UserNameScreen extends StatelessWidget {
//   const UserNameScreen({super.key});

//   Future<void> saveUsername(String username) async {
//     final dbHelper = DatabaseHelper.instance;
//     await dbHelper.insertUsername(username);
//     final usernames = await dbHelper.getUsernames();
//     print('Usernames saved: $usernames');
//   }

//   Future<void> _clearAllUsernames() async {
//     final dbHelper = DatabaseHelper.instance;
//     await dbHelper.clearAllUsernames();
//     print('All usernames removed');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController controller = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Enter Your Name'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 labelText: 'Username',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 final username = controller.text.trim();
//                 if (username.isNotEmpty) {
//                   await saveUsername(username);
//                   if (context.mounted) {
//                     Navigator.pushReplacementNamed(context, 'TodoScreen');
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Username cannot be empty')),
//                   );
//                 }
//               },
//               child: const Text('Save and Continue'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 await _clearAllUsernames();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('All data cleared')),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: const Text('Clear All Data'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/funtions/controller.dart';
import 'package:todo_list/funtions/constants.dart';
import 'package:todo_list/model/todo_list.dart';

class TaskListScreen extends StatelessWidget {
  final TodoController controller = Get.find<TodoController>();
  final TextEditingController _textController = TextEditingController();

  TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
        ),
        flexibleSpace: Center(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 0),
                  ),
                ]),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: kWhiteColor),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Task List',
          style: TextStyle(color: kWhiteColor),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 45.0, left: 16, right: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a task',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 1),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      String userEmail = Get.find<UserController>()
                          .email
                          .value; // Get user email

                      if (userEmail.isNotEmpty) {
                        controller.addTodo(userEmail,
                            _textController.text); // ✅ Pass userEmail & title
                        _textController.clear();
                      } else {
                        Get.snackbar(
                          'Error',
                          'User email not found!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } else {
                      Get.snackbar(
                        'Error',
                        'Task cannot be empty',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Icon(
                    Icons.add,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Expanded(
            //   child: Obx(
            //     () => ListView.builder(
            //       itemCount: controller.todoList.length,
            //       itemBuilder: (context, index) {
            //         final todo = controller.todoList[index];
            //         return ListTile(
            //           leading: IconButton(
            //             icon: Icon(
            //               todo.isCompleted
            //                   ? Icons.check_circle
            //                   : Icons.circle_outlined,
            //               color: todo.isCompleted ? Colors.green : Colors.grey,
            //             ),
            //             onPressed: () {
            //               controller.toggleTodoStatus(index);
            //             },
            //           ),
            //           title: Text(
            //             todo.task,
            //             style: TextStyle(
            //               decoration: todo.isCompleted
            //                   ? TextDecoration.lineThrough
            //                   : TextDecoration.none,
            //             ),
            //           ),
            //           trailing: IconButton(
            //             icon: const Icon(Icons.delete, color: Colors.red),
            //             onPressed: () {
            //               controller.deleteTodoAt(index);
            //             },
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

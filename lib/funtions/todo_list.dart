class Todo {
  String id;
  String title;
  bool isCompleted;
  String userId;
  String task;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.userId,
    required this.task,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'] ?? '',
      task: json['task'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'userId': userId,
      'task': task,
    };
  }
}

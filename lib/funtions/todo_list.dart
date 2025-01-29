class Todo {
  String id;
  String title;
  bool isCompleted;
  String userId;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false, // Default value
    required this.userId, required String task,
  });

  // Convert Firestore Document to Todo
  factory Todo.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['title'] == null || json['userId'] == null) {
      throw ArgumentError('Missing required fields: id, title, or userId');
    }
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'], task: 'task'
    );
  }

  // Convert Todo to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }
}

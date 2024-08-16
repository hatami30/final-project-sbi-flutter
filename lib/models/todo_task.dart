class TodoTask {
  final String? id;
  final String title;
  final bool isCompleted;

  TodoTask({
    this.id,
    required this.title,
    this.isCompleted = false,
  }) {
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty.');
    }
  }

  TodoTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

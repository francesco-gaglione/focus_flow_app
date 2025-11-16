class Task {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final DateTime? scheduledDate;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.scheduledDate,
    required this.completedAt,
  });
}

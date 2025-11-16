class Category {
  final String id;
  final String name;
  final String? description;
  final String color;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/presentation/category/category_bloc.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), elevation: 0),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () =>
                            context.read<CategoryBloc>().add(LoadCategories()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final categories = state.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories yet.\nTap + to create one.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryWithTasks = categories[index];
              final category = categoryWithTasks.category;
              final tasks = categoryWithTasks.tasks;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(category.color),
                    child: Text(
                      category.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle:
                      category.description != null
                          ? Text(
                            category.description!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          )
                          : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditDialog(context, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed:
                            () => _showDeleteDialog(context, category.id),
                      ),
                    ],
                  ),
                  children: [
                    if (tasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No tasks in this category',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...tasks.map(
                        (task) => ListTile(
                          dense: true,
                          leading: Icon(
                            task.completedAt != null
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                task.completedAt != null
                                    ? Colors.green
                                    : Colors.grey,
                            size: 20,
                          ),
                          title: Text(
                            task.name,
                            style: TextStyle(
                              decoration:
                                  task.completedAt != null
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          subtitle:
                              task.description != null
                                  ? Text(
                                    task.description!,
                                    style: const TextStyle(fontSize: 12),
                                  )
                                  : null,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final colorController = TextEditingController(text: '#6200EE');

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Create Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color (hex)',
                      border: OutlineInputBorder(),
                      hintText: '#6200EE',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name is required')),
                    );
                    return;
                  }
                  context.read<CategoryBloc>().add(
                    CreateCategoryEvent(
                      name: nameController.text.trim(),
                      color: colorController.text.trim(),
                      description:
                          descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);
    final colorController = TextEditingController(text: category.color);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Edit Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color (hex)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<CategoryBloc>().add(
                    UpdateCategoryEvent(
                      id: category.id,
                      name:
                          nameController.text.trim().isEmpty
                              ? null
                              : nameController.text.trim(),
                      color:
                          colorController.text.trim().isEmpty
                              ? null
                              : colorController.text.trim(),
                      description:
                          descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Category'),
            content: const Text(
              'Are you sure? This will also delete all tasks in this category.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<CategoryBloc>().add(
                    DeleteCategoryEvent(id: categoryId),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

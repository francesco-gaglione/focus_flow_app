import 'package:flutter/material.dart';
import 'package:focus_flow_app/presentation/widgets/common/custom_text_field.dart';

class OrphanTaskDialog extends StatefulWidget {
  final Function(String name, String? description) onSubmit;

  const OrphanTaskDialog({super.key, required this.onSubmit});

  @override
  State<OrphanTaskDialog> createState() => _OrphanTaskDialogState();
}

class _OrphanTaskDialogState extends State<OrphanTaskDialog> {
  late TextEditingController nameController;
  late TextEditingController descController;

  static const Color _orphanTaskColor = Color(0xFFFFA726);

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      icon: const Icon(Icons.add_task, color: _orphanTaskColor),
      title: const Text('Create Orphan Task'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'Task Name',
                icon: Icons.task_outlined,
                hint: 'Enter task name',
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descController,
                label: 'Description',
                icon: Icons.notes_outlined,
                hint: 'Optional description',
                maxLines: 4,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _orphanTaskColor),
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a task name'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            widget.onSubmit(
              nameController.text.trim(),
              descController.text.trim().isEmpty
                  ? null
                  : descController.text.trim(),
            );
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

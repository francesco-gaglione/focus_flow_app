import 'package:flutter/material.dart';
import 'package:focus_flow_app/presentation/widgets/category/color_picker_advanced.dart';
import 'package:focus_flow_app/presentation/widgets/common/custom_text_field.dart';

class CategoryFormDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? initialName;
  final String? initialDescription;
  final Color? initialColor;
  final Function(String name, String? description, Color color) onSubmit;

  const CategoryFormDialog({
    super.key,
    required this.title,
    required this.icon,
    this.initialName,
    this.initialDescription,
    this.initialColor,
    required this.onSubmit,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    descController = TextEditingController(text: widget.initialDescription);
    selectedColor = widget.initialColor ?? const Color(0xFFEF5350);
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
      icon: Icon(widget.icon),
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'Name',
                icon: Icons.label_outlined,
                hint: 'Enter category name',
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descController,
                label: 'Description',
                icon: Icons.notes_outlined,
                hint: 'Optional description',
                maxLines: 3,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              ColorPickerAdvanced(
                selectedColor: selectedColor,
                onColorSelected:
                    (color) => setState(() => selectedColor = color),
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
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a category name'),
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
              selectedColor,
            );
            Navigator.pop(context);
          },
          child: Text(widget.initialName == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}

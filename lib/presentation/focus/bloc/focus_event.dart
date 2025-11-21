import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/task.dart';

abstract class FocusEvent {}

class InitState extends FocusEvent {}

class CategorySelected extends FocusEvent {
  final Category? category;

  CategorySelected({required this.category});
}

class TaskSelected extends FocusEvent {
  final Task? task;

  TaskSelected({required this.task});
}

class PomodoroStateUpdated extends FocusEvent {
  final dynamic pomodoroState;

  PomodoroStateUpdated(this.pomodoroState);
}

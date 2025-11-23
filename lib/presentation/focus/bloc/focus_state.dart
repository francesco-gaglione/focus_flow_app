import 'package:equatable/equatable.dart';
import 'package:focus_flow_app/adapters/dtos/ws_dtos.dart';
import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/focus_session.dart';
import 'package:focus_flow_app/domain/entities/task.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';

class FocusState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<CategoryWithTasks> categories;
  final List<Task> orphanTasks;
  final Category? selectedCategory;
  final Task? selectedTask;
  final List<FocusSession> todaySessions;
  final SessionState? sessionState;

  const FocusState({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
    this.orphanTasks = const [],
    this.selectedCategory,
    this.selectedTask,
    this.sessionState,
    this.todaySessions = const [],
  });

  FocusState copyWith({
    List<CategoryWithTasks>? categories,
    List<Task>? orphanTasks,
    Category? selectedCategory,
    Task? selectedTask,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearSelectedTask = false,
    int? selectedFocusLevel,
    SessionState? sessionState,
    bool clearSessionState = false,
    List<FocusSession>? todaySessions,
  }) {
    return FocusState(
      categories: categories ?? this.categories,
      orphanTasks: orphanTasks ?? this.orphanTasks,
      selectedCategory:
          clearSelectedCategory
              ? null
              : selectedCategory ?? this.selectedCategory,
      selectedTask:
          clearSelectedTask ? null : selectedTask ?? this.selectedTask,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sessionState:
          clearSessionState ? null : sessionState ?? this.sessionState,
      todaySessions: todaySessions ?? this.todaySessions,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    categories,
    orphanTasks,
    selectedCategory,
    selectedTask,
    sessionState,
    todaySessions,
  ];
}

class SessionState extends Equatable {
  final SessionTypeEnum sessionType;
  final int startDate;
  final int? selectedFocusLevel;
  final String? note;

  const SessionState({
    required this.sessionType,
    required this.startDate,
    this.selectedFocusLevel,
    this.note,
  });

  SessionState copyWith({
    SessionTypeEnum? sessionType,
    int? startDate,
    int? selectedFocusLevel,
    String? note,
  }) {
    return SessionState(
      sessionType: sessionType ?? this.sessionType,
      startDate: startDate ?? this.startDate,
      selectedFocusLevel: selectedFocusLevel ?? this.selectedFocusLevel,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [sessionType, startDate, selectedFocusLevel, note];
}

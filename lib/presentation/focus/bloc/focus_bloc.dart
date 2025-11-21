import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/adapters/ws/ws_repository.dart';
import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/task.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/fetch_orphan_tasks.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_event.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_state.dart';
import 'package:logger/logger.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  final Logger logger = Logger();
  final GetCategoriesAndTasks _getCategoriesAndTasks;
  final FetchOrphanTasks _fetchOrphanTasks;
  final WebsocketRepository _websocketRepository;
  StreamSubscription? _serverResponsesSubscription;
  StreamSubscription? _broadcastEventsSubscription;
  StreamSubscription? _pomodoroStateUpdatesSubscription;

  FocusBloc({
    required GetCategoriesAndTasks getCategoriesAndTask,
    required FetchOrphanTasks fetchOrphanTasks,
    required WebsocketRepository websocketRepository,
  }) : _getCategoriesAndTasks = getCategoriesAndTask,
       _fetchOrphanTasks = fetchOrphanTasks,
       _websocketRepository = websocketRepository,
       super(const FocusState()) {
    on<InitState>(_onInitState);
    on<CategorySelected>(_onCategorySelected);
    on<TaskSelected>(_onTaskSelected);
    on<PomodoroStateUpdated>(_onPomodoroStateUpdated);
  }

  @override
  Future<void> close() {
    _serverResponsesSubscription?.cancel();
    _broadcastEventsSubscription?.cancel();
    _pomodoroStateUpdatesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onInitState(InitState event, Emitter<FocusState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    logger.d('Initializing FocusBloc');
    try {
      logger.d('Checking WebSocket connection...');
      if (!_websocketRepository.isConnected()) {
        logger.d('Connecting to WebSocket...');
        await _websocketRepository.connect();
        logger.d('WebSocket connected');
      }

      // Setup WebSocket message handlers
      _handleWsMessage();

      // Request initial sync
      _websocketRepository.requestSync();

      final result = await _getCategoriesAndTasks.execute();

      if (result.success && result.categoriesWithTasks != null) {
        final categories =
            result.categoriesWithTasks!
                .map(
                  (cat) => CategoryWithTasks(
                    category: cat.category,

                    tasks: cat.tasks,
                  ),
                )
                .toList();

        final tasksResult = await _fetchOrphanTasks.execute();

        emit(
          FocusState(
            categories: categories,
            orphanTasks: tasksResult.orphanTasks ?? [],
            isLoading: false,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: result.error ?? 'Unknown error',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<FocusState> emit,
  ) async {
    logger.d('Category selected: ${event.category?.name}');
    emit(
      state.copyWith(
        selectedCategory: event.category,
        clearSelectedCategory: event.category == null,
        clearSelectedTask: true, // Also clear task when category changes
      ),
    );
    _websocketRepository.updatePomodoroContext(categoryId: event.category?.id);
  }

  Future<void> _onTaskSelected(
    TaskSelected event,
    Emitter<FocusState> emit,
  ) async {
    logger.d('Task selected: ${event.task?.name}');
    emit(
      state.copyWith(
        selectedTask: event.task,
        clearSelectedTask: event.task == null,
      ),
    );

    _websocketRepository.updatePomodoroContext(
      categoryId: state.selectedCategory?.id,
      taskId: event.task?.id,
    );
  }

  /// Handle WebSocket messages from the repository
  void _handleWsMessage() {
    // Listen to server responses (success, error, syncData)
    _serverResponsesSubscription = _websocketRepository.serverResponses.listen((
      response,
    ) {
      response.when(
        success: (message, requestId) {
          logger.i('Server success: $message (requestId: $requestId)');
        },
        error: (code, message, requestId) {
          logger.e('Server error: [$code] $message (requestId: $requestId)');
        },
        syncData: (pomodoroState) {
          logger.d('Received sync data: $pomodoroState');
          // Handle sync data - update state if needed
          _handlePomodoroStateUpdate(pomodoroState);
        },
      );
    });

    // Listen to broadcast events
    _broadcastEventsSubscription = _websocketRepository.broadcastEvents.listen((
      event,
    ) {
      event.when(
        pomodoroSessionUpdate: (pomodoroState) {
          logger.d('Received pomodoro session update: $pomodoroState');
          _handlePomodoroStateUpdate(pomodoroState);
        },
      );
    });

    // Listen to pomodoro state updates
    _pomodoroStateUpdatesSubscription = _websocketRepository
        .pomodoroStateUpdates
        .listen((pomodoroState) {
          logger.d('Received pomodoro state update: $pomodoroState');
          _handlePomodoroStateUpdate(pomodoroState);
        });
  }

  /// Handle pomodoro state updates
  void _handlePomodoroStateUpdate(dynamic pomodoroState) {
    if (isClosed) return;
    add(PomodoroStateUpdated(pomodoroState));
  }

  Future<void> _onPomodoroStateUpdated(
    PomodoroStateUpdated event,
    Emitter<FocusState> emit,
  ) async {
    final pomodoroState = event.pomodoroState;
    logger.d('Pomodoro state - Work context: ${pomodoroState.workContext}');
    Category? selectedCategory;
    Task? selectedTask;
    final categoryId = pomodoroState.workContext.categoryId;
    final taskId = pomodoroState.workContext.taskId;

    if (categoryId != null) {
      try {
        final categoryWithTasks = state.categories.firstWhere(
          (category) => category.category.id == categoryId,
        );
        selectedCategory = categoryWithTasks.category;

        if (taskId != null) {
          try {
            selectedTask = categoryWithTasks.tasks.firstWhere(
              (task) => task.id == taskId,
            );
          } catch (e) {
            logger.w('Task with id $taskId not found in category $categoryId.');
            selectedTask = null; // Explicitly set to null
          }
        }
      } catch (e) {
        logger.w('Category with id $categoryId not found.');
        selectedCategory = null; // Explicitly set to null
      }
    }

    // Handle orphan tasks if no category is selected
    if (selectedCategory == null && taskId != null) {
      try {
        selectedTask = state.orphanTasks.firstWhere(
          (task) => task.id == taskId,
        );
      } catch (e) {
        logger.w('Orphan task with id $taskId not found.');
        selectedTask = null; // Explicitly set to null
      }
    }

    logger.d(
      'Updating state - Category: ${selectedCategory?.name}, Task: ${selectedTask?.name}',
    );
    emit(
      state.copyWith(
        selectedCategory: selectedCategory,
        selectedTask: selectedTask,
        clearSelectedCategory: selectedCategory == null,
        clearSelectedTask: selectedTask == null,
      ),
    );
  }
}

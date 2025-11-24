import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/domain/repositories/statistics_repository.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';
import 'package:focus_flow_app/presentation/statistics/bloc/statistics_event.dart';
import 'package:focus_flow_app/presentation/statistics/bloc/statistics_state.dart';
import 'package:logger/logger.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StatisticsRepository _statisticsRepository;
  final GetCategoriesAndTasks _getCategoriesAndTasks;
  final Logger _logger = Logger();

  StatisticsBloc({
    required StatisticsRepository statisticsRepository,
    required GetCategoriesAndTasks getCategoriesAndTasks,
  }) : _statisticsRepository = statisticsRepository,
       _getCategoriesAndTasks = getCategoriesAndTasks,
       super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<ChangeTimeRange>(_onChangeTimeRange);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());
    try {
      final now = DateTime.now();
      int startDate;
      int? endDate;
      StatisticsTimeRange timeRange = StatisticsTimeRange.day;

      if (event.startDate == null) {
        final startOfDay = DateTime(now.year, now.month, now.day);
        startDate = startOfDay.millisecondsSinceEpoch ~/ 1000;
        endDate =
            startOfDay.add(const Duration(days: 1)).millisecondsSinceEpoch ~/
            1000;
      } else {
        startDate = event.startDate!;
        endDate = event.endDate;
      }

      final stats = await _statisticsRepository.calculateStatsByPeriod(
        startDate: startDate,
        endDate: endDate,
      );


      final categoriesResult = await _getCategoriesAndTasks.execute();
      final categoryColors = <String, Color>{};
      
      if (categoriesResult.success && categoriesResult.categoriesWithTasks != null) {
        for (final item in categoriesResult.categoriesWithTasks!) {
          final category = item.category;
          try {
             categoryColors[category.id] = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
          } catch (e) {
             // Fallback or ignore invalid color
             _logger.w('Invalid color for category ${category.name}: ${category.color}');
          }
        }
      }

      emit(
        StatisticsLoaded(
          statistics: stats,
          timeRange: timeRange,
          categoryColors: categoryColors,
        ),
      );
    } catch (e) {
      _logger.e('Error loading statistics', error: e);
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> _onChangeTimeRange(
    ChangeTimeRange event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());
    try {
      final now = DateTime.now();
      int startDate;
      int? endDate;

      switch (event.timeRange) {
        case StatisticsTimeRange.day:
          final startOfDay = DateTime(now.year, now.month, now.day);
          startDate = startOfDay.millisecondsSinceEpoch ~/ 1000;
          endDate =
              startOfDay.add(const Duration(days: 1)).millisecondsSinceEpoch ~/
              1000;
          break;
        case StatisticsTimeRange.week:
          final startOfWeek = DateTime(
            now.year,
            now.month,
            now.day - (now.weekday - 1),
          );
          startDate = startOfWeek.millisecondsSinceEpoch ~/ 1000;
          endDate =
              startOfWeek.add(const Duration(days: 7)).millisecondsSinceEpoch ~/
              1000;
          break;
        case StatisticsTimeRange.month:
          final startOfMonth = DateTime(now.year, now.month, 1);
          startDate = startOfMonth.millisecondsSinceEpoch ~/ 1000;
          final nextMonth = DateTime(now.year, now.month + 1, 1);
          endDate = nextMonth.millisecondsSinceEpoch ~/ 1000;
          break;
      }

      final stats = await _statisticsRepository.calculateStatsByPeriod(
        startDate: startDate,
        endDate: endDate,
      );

      final categoriesResult = await _getCategoriesAndTasks.execute();
      final categoryColors = <String, Color>{};

      
      if (categoriesResult.success && categoriesResult.categoriesWithTasks != null) {
        for (final item in categoriesResult.categoriesWithTasks!) {
          final category = item.category;
          try {
             categoryColors[category.id] = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
          } catch (e) {
             // Fallback or ignore invalid color
             _logger.w('Invalid color for category ${category.name}: ${category.color}');
          }
        }
      }

      emit(
        StatisticsLoaded(
          statistics: stats,
          timeRange: event.timeRange,
          categoryColors: categoryColors,
        ),
      );
    } catch (e) {
      _logger.e('Error changing time range', error: e);
      emit(StatisticsError(e.toString()));
    }
  }
}

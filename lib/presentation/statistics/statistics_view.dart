import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/domain/entities/statistics.dart';
import 'package:focus_flow_app/presentation/statistics/bloc/statistics_bloc.dart';
import 'package:focus_flow_app/presentation/statistics/bloc/statistics_event.dart';
import 'package:focus_flow_app/presentation/statistics/bloc/statistics_state.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(
      const ChangeTimeRange(StatisticsTimeRange.day),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatisticsError) {
            return Center(child: Text(state.message));
          }

          if (state is StatisticsLoaded) {
            return CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: Text(context.tr('statistics.title')),
                  centerTitle: false,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeRangeSelector(context, state.timeRange),
                        const SizedBox(height: 24),
                        _buildSummaryCards(context, state.statistics),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, context.tr('statistics.activity')),
                        const SizedBox(height: 16),
                        _buildActivityChart(context, state.statistics, state.categoryColors),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, context.tr('statistics.categories')),
                        const SizedBox(height: 16),
                        _buildCategoryDistributionChart(
                          context,
                          state.statistics,
                          state.categoryColors,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, context.tr('statistics.top_tasks')),
                        const SizedBox(height: 16),
                        _buildTopTasksList(context, state.statistics),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, context.tr('statistics.concentration_score')),
                        const SizedBox(height: 16),
                        _buildConcentrationChart(context, state.statistics),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes <= 60) {
      return '${duration.inMinutes}m';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    }
  }

  Widget _buildTimeRangeSelector(
    BuildContext context,
    StatisticsTimeRange currentRange,
  ) {
    return SegmentedButton<StatisticsTimeRange>(
      segments: [
        ButtonSegment(
          value: StatisticsTimeRange.day,
          label: Text(context.tr('statistics.day')),
          icon: const Icon(Icons.calendar_view_day),
        ),
        ButtonSegment(
          value: StatisticsTimeRange.week,
          label: Text(context.tr('statistics.week')),
          icon: const Icon(Icons.calendar_view_week),
        ),
        ButtonSegment(
          value: StatisticsTimeRange.month,
          label: Text(context.tr('statistics.month')),
          icon: const Icon(Icons.calendar_month),
        ),
      ],
      selected: {currentRange},
      onSelectionChanged: (Set<StatisticsTimeRange> newSelection) {
        context.read<StatisticsBloc>().add(
          ChangeTimeRange(newSelection.first),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, PeriodStatistics stats) {
    final duration = Duration(seconds: stats.totalFocusTime);
    final breakDuration = Duration(seconds: stats.totalBreakTime);
    final avgSession = stats.totalSessions > 0 
        ? Duration(seconds: stats.totalFocusTime ~/ stats.totalSessions) 
        : Duration.zero;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                context.tr('statistics.focus_time'),
                _formatDuration(duration),
                Icons.timer,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                context.tr('statistics.sessions'),
                stats.totalSessions.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                context.tr('statistics.break_time'),
                _formatDuration(breakDuration),
                Icons.coffee,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                context.tr('statistics.average_session'),
                _formatDuration(avgSession),
                Icons.timelapse,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                context.tr('statistics.most_productive'),
                stats.mostConcentratedPeriod == ConcentrationPeriod.morning 
                    ? context.tr('statistics.morning') 
                    : context.tr('statistics.afternoon'),
                Icons.wb_sunny,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: _buildSummaryCard(
                context,
                context.tr('statistics.least_productive'),
                stats.lessConcentratedPeriod == ConcentrationPeriod.morning 
                    ? context.tr('statistics.morning') 
                    : context.tr('statistics.afternoon'),
                Icons.nightlight_round,
                Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context, PeriodStatistics stats, Map<String, Color> categoryColors) {
    final dailyActivity = stats.dailyActivity;
    if (dailyActivity.isEmpty) {
      return Center(child: Text(context.tr('statistics.no_activity_data')));
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              dailyActivity
                  .map((e) => e.categoryDistribution.fold(
                    0,
                    (sum, item) => sum + item.totalFocusTime,
                  ))
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() *
              1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= 0 && value.toInt() < dailyActivity.length) {
                     final date = DateTime.fromMillisecondsSinceEpoch(dailyActivity[value.toInt()].date * 1000);
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 10)),
                     );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups:
              dailyActivity.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                
                // Stacked bar rods
                final rods = <BarChartRodStackItem>[];
                double currentY = 0;
                
                for (final dist in activity.categoryDistribution) {
                  final color = categoryColors[dist.categoryId] ?? Theme.of(context).colorScheme.primary;
                  rods.add(BarChartRodStackItem(currentY, currentY + dist.totalFocusTime, color));
                  currentY += dist.totalFocusTime;
                }

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: currentY,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                      rodStackItems: rods,
                      color: Colors.transparent, // Color is handled by stack items
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionChart(
    BuildContext context,
    PeriodStatistics stats,
    Map<String, Color> categoryColors,
  ) {
    final categories = stats.categoryDistribution;
    if (categories.isEmpty) {
      return Center(child: Text(context.tr('statistics.no_category_data')));
    }

    // Sort categories by percentage descending
    final sortedCategories = List<CategoryDistribution>.from(categories)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    return Column(
      children: sortedCategories.map((category) {
        final color = categoryColors[category.categoryId] ?? Theme.of(context).colorScheme.primary;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.categoryName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${category.percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: category.percentage / 100,
                  backgroundColor: color.withValues(alpha: 0.2),
                  color: color,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConcentrationChart(BuildContext context, PeriodStatistics stats) {
    final distribution = stats.concentrationDistribution;
    // distribution is a list of 5 integers representing count for scores 1-5
    
    if (distribution.every((element) => element == 0)) {
       return Center(child: Text(context.tr('statistics.no_activity_data')));
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: distribution.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= 0 && value.toInt() < distribution.length) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text('${value.toInt() + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                     );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: distribution.asMap().entries.map((entry) {
            final index = entry.key;
            final count = entry.value;
            
            // Color gradient from red (1) to green (5)
            final color = HSVColor.fromAHSV(1.0, index * 30.0, 0.8, 0.9).toColor();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: color,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopTasksList(BuildContext context, PeriodStatistics stats) {
    final tasks = stats.taskDistribution;
    if (tasks.isEmpty) {
      return Center(child: Text(context.tr('statistics.no_task_data')));
    }

    return Column(
      children:
          tasks.take(5).map((task) {
            final duration = Duration(seconds: task.totalFocusTime);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primaryContainer,
                child: Text(task.taskName.isNotEmpty ? task.taskName[0].toUpperCase() : '?'),
              ),
              title: Text(task.taskName),
              subtitle: Text(task.categoryName ?? 'Uncategorized'),
              trailing: Text(_formatDuration(duration)),
            );
          }).toList(),
    );
  }
}

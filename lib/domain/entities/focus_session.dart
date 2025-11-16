import 'package:focus_flow_app/domain/entities/focus_session_type.dart';

class FocusSession {
  final String id;
  final String? categoryId;
  final String? taskId;
  final FocusSessionType type;
  final int? actualDuration;
  final int? concentrationScore;
  final String? notes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;

  FocusSession({
    required this.id,
    required this.categoryId,
    required this.taskId,
    required this.type,
    required this.actualDuration,
    required this.concentrationScore,
    required this.notes,
    required this.startedAt,
    this.endedAt,
    this.createdAt,
  });
}

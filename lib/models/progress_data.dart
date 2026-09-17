import 'session_result.dart';

class ProgressData {
  final List<SessionResult> sessions;

  const ProgressData({this.sessions = const []});

  int get totalSessions => sessions.length;
  int get totalCorrect => sessions.fold(0, (sum, s) => sum + s.correct);
  int get totalQuestions => sessions.fold(0, (sum, s) => sum + s.totalQuestions);
  
  double get overallAccuracy {
    if (totalQuestions == 0) return 0.0;
    return totalCorrect / totalQuestions;
  }

  int get bestStreak {
    if (sessions.isEmpty) return 0;
    return sessions.map((s) => s.bestStreak).reduce((a, b) => a > b ? a : b);
  }

  List<SessionResult> recentSessions(int n) {
    final sorted = List<SessionResult>.from(sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted.take(n).toList();
  }

  Map<String, dynamic> toJson() => {
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    final list = json['sessions'] as List?;
    if (list == null) return const ProgressData();
    return ProgressData(
      sessions: list.map((e) => SessionResult.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
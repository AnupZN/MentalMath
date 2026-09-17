import 'enums.dart';

class AppSettings {
  final int questionCount;
  final bool timedMode;
  final int timeLimitSeconds;
  final FeedbackMode feedbackMode;
  final ThemeModePreference themeModePreference;

  const AppSettings({
    this.questionCount = 10,
    this.timedMode = false,
    this.timeLimitSeconds = 20,
    this.feedbackMode = FeedbackMode.instant,
    this.themeModePreference = ThemeModePreference.system,
  });

  AppSettings copyWith({
    int? questionCount,
    bool? timedMode,
    int? timeLimitSeconds,
    FeedbackMode? feedbackMode,
    ThemeModePreference? themeModePreference,
  }) {
    return AppSettings(
      questionCount: questionCount ?? this.questionCount,
      timedMode: timedMode ?? this.timedMode,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      feedbackMode: feedbackMode ?? this.feedbackMode,
      themeModePreference: themeModePreference ?? this.themeModePreference,
    );
  }

  Map<String, dynamic> toJson() => {
    'questionCount': questionCount,
    'timedMode': timedMode,
    'timeLimitSeconds': timeLimitSeconds,
    'feedbackMode': feedbackMode.name,
    'themeModePreference': themeModePreference.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      questionCount: json['questionCount'] as int? ?? 10,
      timedMode: json['timedMode'] as bool? ?? false,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 20,
      feedbackMode: FeedbackMode.values.firstWhere(
        (e) => e.name == json['feedbackMode'],
        orElse: () => FeedbackMode.instant,
      ),
      themeModePreference: ThemeModePreference.values.firstWhere(
        (e) => e.name == json['themeModePreference'],
        orElse: () => ThemeModePreference.system,
      ),
    );
  }
}
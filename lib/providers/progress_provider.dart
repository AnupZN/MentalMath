import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_data.dart';
import '../models/session_result.dart';
import '../services/persistence_service.dart';
import 'shared_preferences_provider.dart';

class ProgressNotifier extends AsyncNotifier<ProgressData> {
  late PersistenceService _persistenceService;

  @override
  FutureOr<ProgressData> build() {
    _persistenceService = PersistenceService(ref.watch(sharedPreferencesProvider));
    return _persistenceService.loadProgressData();
  }

  Future<void> addSessionResult(SessionResult result) async {
    final current = state.value ?? const ProgressData();
    final updated = ProgressData(sessions: [...current.sessions, result]);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _persistenceService.saveProgressData(updated);
      return updated;
    });
  }
}

final progressProvider = AsyncNotifierProvider<ProgressNotifier, ProgressData>(ProgressNotifier.new);
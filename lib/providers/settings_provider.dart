import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/persistence_service.dart';
import 'shared_preferences_provider.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late PersistenceService _persistenceService;

  @override
  FutureOr<AppSettings> build() {
    _persistenceService = PersistenceService(ref.watch(sharedPreferencesProvider));
    return _persistenceService.loadSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _persistenceService.saveSettings(settings);
      return settings;
    });
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
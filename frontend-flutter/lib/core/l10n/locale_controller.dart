import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const authStorageKey = 'tms_geosun_auth';
const languageStorageKey = 'app-language';

/// Підтримувані мови інтерфейсу (uk — за замовчуванням, як у Angular).
enum AppLanguage {
  uk('uk', 'UA'),
  en('en', 'EN'),
  ru('ru', 'RU');

  const AppLanguage(this.code, this.shortLabel);

  final String code;

  /// Код на кнопці вибору мови — завжди латиницею, без локалізації.
  final String shortLabel;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (item) => item.code == code,
      orElse: () => AppLanguage.uk,
    );
  }

  Locale get locale => Locale(code);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences має бути ініціалізовано в main()',
  );
});

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(languageStorageKey);
    return AppLanguage.fromCode(saved).locale;
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(languageStorageKey, language.code);
    state = language.locale;
  }
}

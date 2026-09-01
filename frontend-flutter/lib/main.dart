import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'auth/state/auth_controller.dart';
import 'core/http/health_service.dart';
import 'core/l10n/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  container.read(authControllerProvider.notifier).attachInterceptor();
  await container.read(backendAvailabilityProvider.notifier).checkOnStartup();
  await container.read(authControllerProvider.notifier).bootstrap();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TmsGeosunApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/shared/timer_provider.dart';
import 'core/shared/theme.dart';
import 'features/home/home_page.dart';
import 'features/break/break_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/settings/settings_page.dart';
import 'core/services/background_service.dart';
import 'features/break/overlay_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayWidget());
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: MaterialApp.router(
        title: 'Blink - Eye Health App',
        theme: AppTheme.lightTheme,
        routerConfig: _router(hasSeenOnboarding),
      ),
    );
  }
}

GoRouter _router(bool hasSeenOnboarding) {
  return GoRouter(
    initialLocation: hasSeenOnboarding ? '/' : '/onboarding',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/break',
        builder: (context, state) => const BreakPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

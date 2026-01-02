import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/shared/timer_provider.dart';
import 'core/shared/theme.dart';
import 'features/home/home_page.dart';
import 'features/break/break_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/settings/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: MaterialApp.router(
        title: '20s - Eye Health App',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
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

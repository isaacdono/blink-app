import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/shared/timer_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _blinkAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 90),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.1), weight: 5),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 1.0), weight: 5),
    ]).animate(CurvedAnimation(parent: _blinkController, curve: Curves.linear));

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    if (timerProvider.appState == AppState.onboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/onboarding'));
      return const SizedBox();
    }

    final isBreakReady = timerProvider.appState == AppState.breakReady;
    final formattedTime = '${(timerProvider.secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(timerProvider.secondsRemaining % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Blink',
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            timerProvider.testBreak();
                            context.go('/break');
                          },
                          icon: const Icon(Icons.visibility),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            shape: const CircleBorder(),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.go('/settings'),
                          icon: const Icon(Icons.settings),
                          style: IconButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Mascot
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _blinkAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 24,
                                  height: 36 * _blinkAnimation.value,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 32),
                            AnimatedBuilder(
                              animation: _blinkAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 24,
                                  height: 36 * _blinkAnimation.value,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 24,
                          height: 8,
                          decoration: BoxDecoration(
                            border: const Border(bottom: BorderSide(color: Colors.black, width: 3)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Text
                Text(
                  isBreakReady ? "Hora de descansar!" : "Relaxe seus olhos",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "A cada 20 minutos, olhe para algo a 6 metros por 20 segundos para relaxar sua visão.",
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Timer Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Próxima pausa em",
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      if (isBreakReady)
                        ElevatedButton(
                          onPressed: () => context.go('/break'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Fazer pausa agora", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        )
                      else
                        OutlinedButton(
                          onPressed: timerProvider.snoozeOneHour,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.coffee),
                              SizedBox(width: 8),
                              Text("Adiar por 1 hora", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Stats
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text("Você fez ${timerProvider.breaksCompletedToday} pausas hoje", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
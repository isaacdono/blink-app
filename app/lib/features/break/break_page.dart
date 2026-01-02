import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/shared/timer_provider.dart';

class BreakPage extends StatefulWidget {
  const BreakPage({super.key});

  @override
  State<BreakPage> createState() => _BreakPageState();
}

class _BreakPageState extends State<BreakPage> with TickerProviderStateMixin {
  bool _isPreparing = true;
  int _prepSeconds = 5;
  Timer? _prepTimer;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  DateTime? _breakStartTime;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _startPreparation();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startPreparation() {
    _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prepSeconds > 1) {
        setState(() {
          _prepSeconds--;
        });
      } else {
        _prepTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _isPreparing = false;
        });
        final timerProvider = Provider.of<TimerProvider>(context, listen: false);
        timerProvider.startBreak('look_away');
        _breakStartTime = DateTime.now();
        _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    _prepTimer?.cancel();
    _progressTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    if (timerProvider.appState == AppState.idle || timerProvider.appState == AppState.onboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: _isPreparing || timerProvider.appState == AppState.breakInProgress 
          ? Colors.black 
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isPreparing
                      ? _buildPrep(context)
                      : timerProvider.appState == AppState.breakInProgress
                          ? _buildProgress(context, timerProvider)
                          : _buildReflection(context, timerProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrep(BuildContext context) {
    return Center(
      key: const ValueKey('prep'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Prepare-se",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Respire um pouco",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            _prepSeconds.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context, TimerProvider timerProvider) {
    final elapsed = _breakStartTime != null ? DateTime.now().difference(_breakStartTime!).inMilliseconds / 1000 : 0.0;
    final progress = timerProvider.totalBreakSeconds > 0 ? (elapsed / timerProvider.totalBreakSeconds).clamp(0.0, 1.0) : 0.0;
    return Column(
      key: const ValueKey('progress'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Olhe para longe e pisque lentamente",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 64),
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: child,
            );
          },
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
                Text(
                  timerProvider.secondsRemaining.toString(),
                  style: const TextStyle(
                    fontSize: 80,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReflection(BuildContext context, TimerProvider timerProvider) {
    return Column(
      key: const ValueKey('reflection'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          "Pausa concluída!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Tem certeza que quer continuar no celular?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 64),
        ElevatedButton(
          onPressed: timerProvider.finishReflection,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text(
            "Continuar no celular",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            timerProvider.finishReflection();
            context.go('/');
          },
          child: Text(
            "Sair um pouco",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
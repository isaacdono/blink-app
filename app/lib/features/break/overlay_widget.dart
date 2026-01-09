import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/services.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> with TickerProviderStateMixin {
  late bool _isPreparing;
  late bool _isReflecting;
  late int _prepSeconds;
  final int _totalBreakSeconds = 20;
  DateTime? _breakStartTime;
  Timer? _timer;
  Timer? _smoothTimer;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  void _resetState() {
    _isPreparing = true;
    _isReflecting = false;
    _prepSeconds = 5;
    _breakStartTime = null;
  }

  @override
  void initState() {
    super.initState();
    // Força modo imersivo (esconde barra de status e navegação)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _resetState();
    _startTimer();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Restaura o modo de UI padrão ao fechar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPreparing) {
        if (_prepSeconds > 1) {
          setState(() => _prepSeconds--);
        } else {
          setState(() {
            _isPreparing = false;
            _breakStartTime = DateTime.now();
          });
          _startSmoothTimer();
        }
      } else if (!_isReflecting) {
        final elapsed = DateTime.now().difference(_breakStartTime!).inSeconds;
        if (elapsed >= _totalBreakSeconds) {
           setState(() {
            _isReflecting = true;
          });
          _timer?.cancel();
          _smoothTimer?.cancel();
        }
      }
    });
  }

  void _startSmoothTimer() {
    _smoothTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Garante que a barra de status tenha texto claro (branco) sobre o fundo escuro
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isPreparing
                    ? _buildPreparation()
                    : (_isReflecting ? _buildReflection() : _buildProgress()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreparation() {
    return Column(
      key: const ValueKey('prep'),
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
    );
  }

  Widget _buildProgress() {
    final elapsed = _breakStartTime != null ? DateTime.now().difference(_breakStartTime!).inMilliseconds / 1000 : 0.0;
    final progress = _totalBreakSeconds > 0 ? (elapsed / _totalBreakSeconds).clamp(0.0, 1.0) : 0.0;
    final secondsRemaining = (_totalBreakSeconds - elapsed).ceil().clamp(0, _totalBreakSeconds);

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
                  secondsRemaining.toString(),
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

  Widget _buildReflection() {
    return Column(
      key: const ValueKey('reflection'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          "Pausa concluída!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Tem certeza que quer continuar no celular?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 64),
        ElevatedButton(
          onPressed: () {
            FlutterOverlayWindow.closeOverlay();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
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
            FlutterOverlayWindow.closeOverlay();
          },
          child: Text(
            "Sair um pouco",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

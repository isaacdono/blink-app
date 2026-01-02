import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> with TickerProviderStateMixin {
  bool _isPreparing = true;
  int _prepSeconds = 5;
  int _breakSeconds = 20;
  Timer? _timer;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPreparing) {
        if (_prepSeconds > 1) {
          setState(() => _prepSeconds--);
        } else {
          setState(() => _isPreparing = false);
        }
      } else {
        if (_breakSeconds > 0) {
          setState(() => _breakSeconds--);
        } else {
          _timer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF), // Cor padrão do app
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isPreparing ? _buildPrep() : _buildProgress(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrep() {
    return Center(
      key: const ValueKey('prep'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Prepare-se",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 24),
          ),
          const SizedBox(height: 16),
          const Text(
            "Respire um pouco",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Text(
            _prepSeconds.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Center(
      key: const ValueKey('progress'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Olhe para longe e pisque lentamente",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                      value: _breakSeconds / 20,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                    ),
                  ),
                  Text(
                    _breakSeconds.toString(),
                    style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 64),
          if (_breakSeconds == 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () async {
                await FlutterOverlayWindow.closeOverlay();
              },
              child: const Text("Concluir Pausa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

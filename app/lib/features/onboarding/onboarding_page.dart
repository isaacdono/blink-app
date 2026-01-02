import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/shared/timer_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  final steps = [
    {
      'title': "Sua visão pede uma pausa",
      'description': "Passamos horas olhando telas. Ajudamos você a dar o descanso que seus olhos merecem.",
      'icon': Icons.visibility,
    },
    {
      'title': "Notificações",
      'description': "Para manter o timer funcionando em segundo plano, precisamos enviar notificações.",
      'icon': Icons.notifications_active,
    },
    {
      'title': "Sobreposição de tela",
      'description': "Para mostrar a pausa no tempo certo, o Blink precisa da permissão de sobreposição de tela.",
      'icon': Icons.layers,
    },
    {
      'title': "Hábito sem esforço",
      'description': "Tudo acontece no tempo certo. Você só precisa olhar para longe.",
      'icon': Icons.flash_on,
    },
  ];

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
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotColor = Theme.of(context).primaryColor.withOpacity(0.1);
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            _handleBack();
          } else if (details.globalPosition.dx > screenWidth * 2 / 3) {
            _handleNext();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                children: List.generate(
                  steps.length,
                  (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: i <= currentStep ? 1.0 : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Mascot Container (Round)
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: mascotColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
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
              const Spacer(),
              // Text
              Text(
                steps[currentStep]['title'] as String,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                steps[currentStep]['description'] as String,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Button
              ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  (currentStep == 1 || currentStep == 2) ? "Configurar permissão" : (currentStep == steps.length - 1 ? "Começar" : "Próximo"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (currentStep == 1) {
      // Notification Permission
      final status = await Permission.notification.status;
      if (status.isGranted) {
        setState(() => currentStep++);
        return;
      }
      final result = await Permission.notification.request();
      if (result.isGranted) {
        setState(() => currentStep++);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A permissão de notificação é necessária para o timer.')),
          );
        }
      }
      return;
    }

    if (currentStep == 2) {
      // Overlay Permission
      final status = await Permission.systemAlertWindow.status;
      if (status.isGranted) {
        setState(() => currentStep++);
        return;
      }
      // Request permission
      final result = await Permission.systemAlertWindow.request();
      if (result.isGranted) {
        setState(() => currentStep++);
      } else if (result.isPermanentlyDenied) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text('Você negou permanentemente a permissão de sobreposição. Abra as configurações do sistema para permitir.'),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Abrir Configurações'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
        return;
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text('Para funcionar em background e mostrar a pausa sobre outros apps, o Blink precisa da permissão de sobreposição de tela.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      return;
    }
    if (currentStep < steps.length - 1) {
      setState(() => currentStep++);
    } else {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      timerProvider.completeOnboarding();
      context.go('/');
    }
  }

  void _handleBack() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }
}
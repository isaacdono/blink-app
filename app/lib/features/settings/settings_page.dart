import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../core/shared/timer_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showPermissionDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showHourPicker(BuildContext context, String title, int currentValue, Function(int) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    final isSelected = index == currentValue;
                    return InkWell(
                      onTap: () {
                        onSelected(index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "${index.toString().padLeft(2, '0')}:00",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourSelector(BuildContext context, String label, int value, Function(int) onChanged) {
    return InkWell(
      onTap: () => _showHourPicker(context, label, value, onChanged),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${value.toString().padLeft(2, '0')}:00",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text("Configurações", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              
              // Active Hours
              Row(
                children: [
                  const Icon(Icons.wb_sunny, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text("Horário Ativo", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Início", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        _buildHourSelector(
                          context, 
                          "Horário de Início", 
                          timerProvider.settings.activeStartHour, 
                          (val) => timerProvider.updateSettings(timerProvider.settings..activeStartHour = val)
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Fim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        _buildHourSelector(
                          context, 
                          "Horário de Término", 
                          timerProvider.settings.activeEndHour, 
                          (val) => timerProvider.updateSettings(timerProvider.settings..activeEndHour = val)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Interval
              Row(
                children: [
                  const Icon(Icons.schedule, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text("Intervalo entre pausas", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [15, 20, 30].map((mins) => Expanded(
                  child: GestureDetector(
                    onTap: () => timerProvider.updateSettings(timerProvider.settings..intervalMinutes = mins),
                    child: Container(
                      height: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: timerProvider.settings.intervalMinutes == mins ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                        border: Border.all(
                          color: timerProvider.settings.intervalMinutes == mins ? Theme.of(context).primaryColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text("$mins min", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: timerProvider.settings.intervalMinutes == mins ? Theme.of(context).primaryColor : Colors.grey,
                        )),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 32),

              // Break Duration
              Row(
                children: [
                  const Icon(Icons.timer, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text("Duração da pausa", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [20, 30, 40, 60].map((secs) => Expanded(
                  child: GestureDetector(
                    onTap: () => timerProvider.updateSettings(timerProvider.settings..breakDurationSeconds = secs),
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: timerProvider.settings.breakDurationSeconds == secs ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                        border: Border.all(
                          color: timerProvider.settings.breakDurationSeconds == secs ? Theme.of(context).primaryColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text("${secs}s", style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: timerProvider.settings.breakDurationSeconds == secs ? Theme.of(context).primaryColor : Colors.grey,
                        )),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 32),

              // Soft Mode Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: SwitchListTile(
                  title: const Text("Modo Suave", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Mostra apenas uma notificação em vez de bloquear a tela inteira."),
                  value: timerProvider.settings.softMode,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (bool value) {
                    timerProvider.updateSettings(timerProvider.settings..softMode = value);
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Permissions
              Row(
                children: [
                  const Icon(Icons.security, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text("Permissões", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Notificações"),
                      subtitle: const Text("Necessário para o timer em segundo plano"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final status = await Permission.notification.status;
                        if (status.isGranted) {
                          if (context.mounted) {
                            _showPermissionDialog(context, "Notificações", "A permissão de notificações já foi concedida.");
                          }
                        } else {
                          await Permission.notification.request();
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text("Permitir Sobreposição"),
                      subtitle: const Text("Necessário para pausas em segundo plano"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final bool status = await FlutterOverlayWindow.isPermissionGranted();
                        if (!status) {
                          await FlutterOverlayWindow.requestPermission();
                        } else {
                          if (context.mounted) {
                            _showPermissionDialog(context, "Sobreposição", "A permissão de sobreposição de tela já foi concedida.");
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Botão de Teste Rápido
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    FlutterBackgroundService().invoke('force_overlay');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comando enviado! O overlay deve aparecer em breve.')),
                    );
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text("Testar Overlay Agora"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    foregroundColor: Colors.orange,
                    elevation: 0,
                    minimumSize: const Size(200, 50),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Footer
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Placeholder for rating
                      },
                      icon: const Icon(Icons.star_outline),
                      label: const Text("Avaliar o Blink"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        foregroundColor: Theme.of(context).primaryColor,
                        elevation: 0,
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "© 2026 Blink Eye Health",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Text(
                      "Feito com carinho para seus olhos.",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
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
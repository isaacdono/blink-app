import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide NotificationVisibility;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notif;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:screen_state/screen_state.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'blink_foreground', // id alterado
    'Blink Timer Service', // title
    description: 'Mantém o timer de saúde ocular ativo.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicialização necessária para configurar o ícone padrão
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'blink_foreground',
      initialNotificationTitle: 'Blink está rodando',
      initialNotificationContent: 'Calculando próxima pausa...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Garante a inicialização dos bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Removido DartPluginRegistrant.ensureInitialized() daqui pois pode causar o erro de Isolate
  // em algumas versões do Flutter quando chamado dentro do onStart do background service.

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Configuração da notificação inicial
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Blink",
      content: "Iniciando timer...",
    );
  }

  int counter = 0;
  int intervalSeconds = 20 * 60; // Default 20 min

  // Monitora o estado da tela (bloqueio/desbloqueio)
  final Screen _screen = Screen();
  _screen.screenStateStream?.listen((ScreenStateEvent event) {
    // Se a tela for bloqueada ou desligada, resetamos o timer
    if (event == ScreenStateEvent.SCREEN_OFF || event == ScreenStateEvent.SCREEN_ON) {
      counter = 0;
      print("FLUTTER: Tela alterada ($event), resetando timer.");
    }
  });

  // Carrega o intervalo inicial
  final prefs = await SharedPreferences.getInstance();
  final settingsJson = prefs.getString('settings');
  if (settingsJson != null) {
    final settings = jsonDecode(settingsJson);
    intervalSeconds = (settings['intervalMinutes'] ?? 20) * 60;
  }

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    counter++;
    
    if (counter >= intervalSeconds) {
      counter = 0;
      // Recarrega as configurações a cada ciclo para pegar mudanças feitas no app
      final updatedPrefs = await SharedPreferences.getInstance();
      final updatedSettingsJson = updatedPrefs.getString('settings');
      if (updatedSettingsJson != null) {
        final updatedSettings = jsonDecode(updatedSettingsJson);
        intervalSeconds = (updatedSettings['intervalMinutes'] ?? 20) * 60;
      }

      if (await FlutterOverlayWindow.isPermissionGranted()) {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Blink Break",
          overlayContent: "Hora de descansar os olhos!",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: WindowSize.matchParent,
          width: WindowSize.matchParent,
        );
      }
    }

    // Envia para a UI (Home)
    service.invoke('update', {
      "seconds_remaining": intervalSeconds - counter,
    });

    // Atualiza a notificação na bandeja
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Blink está rodando",
        content: "Próxima pausa em: ${((intervalSeconds - counter) / 60).floor()}m ${((intervalSeconds - counter) % 60)}s",
      );
    }
  });
}

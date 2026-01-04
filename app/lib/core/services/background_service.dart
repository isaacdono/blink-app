import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide NotificationVisibility;
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
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Cria o canal do Overlay com importância MÍNIMA para não aparecer na status bar
  const AndroidNotificationChannel overlayChannel = AndroidNotificationChannel(
    'Overlay Channel', // ID fixo do flutter_overlay_window
    'Foreground Service Channel', // Nome usado pelo plugin
    description: 'Canal silencioso para o overlay',
    importance: Importance.min, // Minima importância
    playSound: false,
    enableVibration: false,
    showBadge: false,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(overlayChannel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'blink_foreground',
      initialNotificationTitle: 'Blink está rodando',
      initialNotificationContent: 'Calculando próxima pausa...',
      foregroundServiceNotificationId: 888
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
  // Garante a inicialização dos bindings e registro de plugins
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicialização necessária para configurar o ícone padrão e permitir chamadas de plugins
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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

  // Listener para forçar o overlay (Debug/Teste)
  service.on('force_overlay').listen((event) async {
    print("FLUTTER: Forçando overlay via comando de teste...");
    bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
    if (hasPermission) {
      try {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: false,
          overlayTitle: " ", // Espaço vazio para minimizar a notificação
          overlayContent: " ",
          flag: OverlayFlag.focusPointer,
          visibility: NotificationVisibility.visibilitySecret, // Tenta esconder do lockscreen
          positionGravity: PositionGravity.none,
          height: WindowSize.fullCover,
          width: WindowSize.fullCover,
          alignment: OverlayAlignment.topLeft,
          startPosition: const OverlayPosition(0, 0),
        );
        print("FLUTTER: Overlay de teste chamado com sucesso.");
      } catch (e) {
        print("FLUTTER: Erro ao mostrar overlay de teste: $e");
      }
    } else {
      print("FLUTTER: Permissão negada para overlay de teste.");
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
      bool softMode = false;
      if (updatedSettingsJson != null) {
        final updatedSettings = jsonDecode(updatedSettingsJson);
        intervalSeconds = (updatedSettings['intervalMinutes'] ?? 20) * 60;
        softMode = updatedSettings['softMode'] ?? false;
      }

      if (softMode) {
        // Modo Suave: Apenas notificação
        print("FLUTTER: Modo Suave ativado. Enviando notificação.");
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'blink_break_notification', // ID diferente do canal do serviço
          'Blink Break Alerts',
          channelDescription: 'Notificações para hora de pausa',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: 'ic_stat_blink',
          fullScreenIntent: true, // Tenta chamar atenção
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        
        await flutterLocalNotificationsPlugin.show(
          999, // ID da notificação de break
          'Blink Break',
          'Hora de descansar os olhos! Toque para iniciar.',
          platformChannelSpecifics,
          payload: 'break_page',
        );
      } else {
        // Modo Normal: Tenta abrir Overlay
        // Verifica permissão antes de tentar abrir
        bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
        print("FLUTTER: Overlay permission granted? $hasPermission");

        if (hasPermission) {
          print("FLUTTER: Tentando mostrar overlay...");
          try {
          await FlutterOverlayWindow.showOverlay(
            enableDrag: false,
            overlayTitle: " ", // Espaço vazio para minimizar a notificação
            overlayContent: " ",
            flag: OverlayFlag.focusPointer,
            visibility: NotificationVisibility.visibilitySecret, // Tenta esconder do lockscreen
            positionGravity: PositionGravity.none,
            height: WindowSize.fullCover,
            width: WindowSize.fullCover,
            alignment: OverlayAlignment.topLeft,
            startPosition: const OverlayPosition(0, 0),
          );
          print("FLUTTER: Overlay chamado com sucesso.");
          } catch (e) {
            print("FLUTTER: Erro ao mostrar overlay: $e");
          }
        } else {
          print("FLUTTER: Permissão de overlay negada. Enviando notificação.");
          // Se não tiver permissão, avisa na notificação
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "Blink: Permissão necessária",
              content: "Abra o app e permita a sobreposição de tela.",
            );
          }
        }
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

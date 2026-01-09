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
  bool _screenLocked = false;
  DateTime? _screenOffTime;

  // Monitora o estado da tela (bloqueio/desbloqueio)
  final Screen _screen = Screen();
  _screen.screenStateStream?.listen((ScreenStateEvent event) {
    // Rastreia o estado da tela para evitar mostrar overlay ao desbloquear
    if (event == ScreenStateEvent.SCREEN_OFF) {
      _screenLocked = true;
      _screenOffTime = DateTime.now();
      print("FLUTTER: Tela bloqueada, pausando timer.");
      
      // Update notification immediately
      if (service is AndroidServiceInstance) {
         service.setForegroundNotificationInfo(
          title: "Blink em pausa",
          content: "O timer continua quando você voltar.",
        );
      }

    } else if (event == ScreenStateEvent.SCREEN_ON) {
      _screenLocked = false;
      print("FLUTTER: Tela desbloqueada, retomando timer.");
      
      if (_screenOffTime != null) {
         final adjustment = DateTime.now().difference(_screenOffTime!);
         // Se a pausa foi maior que 60 segundos, reseta o timer
         if (adjustment.inSeconds > 60) {
             counter = 0;
             print("FLUTTER: Pausa longa (${adjustment.inSeconds}s), resetando timer.");
         }
         _screenOffTime = null;
      }
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
  bool softMode = false;
  int breakDurationSeconds = 20;
  int activeStartHour = 9;
  int activeEndHour = 18;

  if (settingsJson != null) {
    final settings = jsonDecode(settingsJson);
    intervalSeconds = (settings['intervalMinutes'] ?? 20) * 60;
    softMode = settings['softMode'] ?? false;
    breakDurationSeconds = settings['breakDurationSeconds'] ?? 20;
    activeStartHour = settings['activeStartHour'] ?? 9;
    activeEndHour = settings['activeEndHour'] ?? 18;
  }

  // Listener para atualização de configurações em tempo real
  service.on('update_settings').listen((event) {
    if (event != null) {
      print("FLUTTER: Atualizando configurações em background...");
      if (event['intervalMinutes'] != null) {
        intervalSeconds = event['intervalMinutes'] * 60;
      }
      if (event['softMode'] != null) {
        softMode = event['softMode'];
      }
      if (event['breakDurationSeconds'] != null) {
        breakDurationSeconds = event['breakDurationSeconds'];
      }
      if (event['activeStartHour'] != null) {
        activeStartHour = event['activeStartHour'];
      }
      if (event['activeEndHour'] != null) {
        activeEndHour = event['activeEndHour'];
      }
    }
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    // Apenas incrementa o contador se a tela estiver desbloqueada
    if (!_screenLocked) {
      counter++;
    }
    
    if (counter >= intervalSeconds && !_screenLocked) {
      counter = 0;
      
      // Verifica se a hora atual está dentro do intervalo ativo
      final now = DateTime.now();
      final currentHour = now.hour;
      final isWithinActiveHours = currentHour >= activeStartHour && currentHour < activeEndHour;

      if (!isWithinActiveHours) {
        print("FLUTTER: Horário atual ($currentHour) fora do intervalo ativo ($activeStartHour-$activeEndHour). Ignorando pausa.");
        return;
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
        print("FLUTTER: Notificação enviada em modo suave.");
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
      if (!_screenLocked) {
        service.setForegroundNotificationInfo(
          title: "Blink está rodando",
          content: "Próxima pausa em: ${((intervalSeconds - counter) / 60).floor()}m ${((intervalSeconds - counter) % 60)}s",
        );
      }
    }
  });
}

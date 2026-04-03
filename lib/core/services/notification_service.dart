import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:alarm/alarm.dart';
import '../../models/models.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (notificationResponse.payload != null) {
    try {
      final Map<String, dynamic> data = jsonDecode(notificationResponse.payload!);
      final int id = data['id'];
      final String nombre = data['nombre'];
      final String soundPath = data['finalPath'];

      await Alarm.init();
      await Alarm.stop(id);

      int minutes = 0;
      switch (notificationResponse.actionId) {
        case 'snooze_15': minutes = 15; break;
        case 'snooze_30': minutes = 30; break;
        case 'snooze_45': minutes = 45; break;
        case 'snooze_60': minutes = 60; break;
      }

      if (minutes > 0) {
        final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
        final alarmSettings = AlarmSettings(
          id: id,
          dateTime: snoozeTime,
          assetAudioPath: soundPath,
          loopAudio: true,
          vibrate: true,
          volumeSettings: const VolumeSettings.fixed(volume: 1.0),
          notificationSettings: NotificationSettings(
            title: 'ALERTA POSPUESTA ($minutes min)',
            body: 'Cliente: $nombre. Tocar para opciones.',
            stopButton: 'APAGAR',
            icon: 'ic_launcher',
          ),
        );
        await Alarm.set(alarmSettings: alarmSettings);
      }
    } catch (e) {
      debugPrint("NOTIFICATION_BACKGROUND_ERROR: $e");
    }
  }
}

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneInfo.toString()));
      } catch (_) {}

      await Alarm.init();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Foreground
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'werkflow_snooze_channel_v4',
        'Citas con Posponer',
        description: 'Muestra opciones de tiempo para las alertas',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

    } catch (e) {
      debugPrint("NOTIFICATION_INIT_ERROR: $e");
    }
  }

  Future<void> scheduleCitaNotification(Cita cita, Cliente? cliente) async {
    if (cita.id == null) return;

    final now = DateTime.now();
    var scheduledDateTime = cita.fechaHora;
    
    if (scheduledDateTime.isBefore(now)) {
      if (now.difference(scheduledDateTime).inMinutes < 5) {
        scheduledDateTime = now.add(const Duration(seconds: 10));
      } else {
        return; 
      }
    }

    String? soundPath = (cita.sonido != null && cita.sonido!.isNotEmpty) 
        ? cita.sonido! 
        : 'assets/alarma_1.mp3';
        
    try {
      const platform = MethodChannel('com.werkflow.alarms/sounds');
      final String? preparedPath = await platform.invokeMethod('prepareAlarmPath', {'uri': soundPath});
      final finalSoundPath = preparedPath ?? 'assets/alarma_1.mp3';

      final String nombreCliente = cliente?.nombre ?? 'Cliente';
      
      final payload = jsonEncode({
        'id': cita.id,
        'nombre': nombreCliente,
        'finalPath': finalSoundPath,
      });

      final tzTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
      
      // Notificación con acciones Y Full Screen Intent
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: cita.id!,
        title: 'CITA CON: $nombreCliente',
        body: 'Seleccione tiempo para posponer:',
        scheduledDate: tzTime,
        payload: payload,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'werkflow_snooze_channel_v4',
            'Citas con Posponer',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true, // Esto hará que la app se abra
            ticker: 'Alerta de Cita',
            styleInformation: BigTextStyleInformation(''),
            actions: <AndroidNotificationAction>[
              const AndroidNotificationAction('snooze_15', '15m', titleColor: Color(0xFF2196F3)),
              const AndroidNotificationAction('snooze_30', '30m', titleColor: Color(0xFF2196F3)),
              const AndroidNotificationAction('snooze_45', '45m', titleColor: Color(0xFF2196F3)),
              const AndroidNotificationAction('snooze_60', '1h', titleColor: Color(0xFF2196F3)),
              const AndroidNotificationAction('dismiss_action', 'APAGAR', titleColor: Color(0xFFFF5252)),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      final alarmSettings = AlarmSettings(
        id: cita.id!,
        dateTime: scheduledDateTime,
        assetAudioPath: finalSoundPath, 
        loopAudio: true,
        vibrate: true,
        volumeSettings: const VolumeSettings.fixed(volume: 1.0),
        notificationSettings: NotificationSettings(
          title: '¡ALERTA DE CITA!',
          body: 'Cliente: $nombreCliente. Toque para ver opciones.',
          stopButton: 'POSPONER', // Cambiamos el texto para invitar a tocar
          icon: 'ic_launcher',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      debugPrint("ALARM_PLANIFICADA_ERROR: $e");
    }
  }

  Future<void> cancelCitaNotification(int citaId) async {
    await flutterLocalNotificationsPlugin.cancel(id: citaId);
    await Alarm.stop(citaId);
  }
}

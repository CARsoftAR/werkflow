import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../models/models.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize timezone data
    tz.initializeTimeZones();
    // Setting to Argentina timezone as a stable fallback for now
    tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires')); 

    // 2. Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 4. Combined settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 5. Initialize the plugin
    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );

    // 6. Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleCitaNotification(Cita cita, Cliente? cliente) async {
    // Prevent scheduling if date is in the past
    if (cita.fechaHora.isBefore(DateTime.now())) return;

    final scheduleTime = tz.TZDateTime.from(cita.fechaHora, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id: cita.id ?? 999,
      title: '¡URGENTE: VISITA PROGRAMADA!',
      body: 'Tienes una visita ahora con ${cliente?.nombre ?? "un cliente"}.',
      scheduledDate: scheduleTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'werkflow_alarms_v3', 
          'Alarmas Críticas',
          channelDescription: 'Canal para alarmas que deben sonar incluso en silencio',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelCitaNotification(int citaId) async {
    await _notificationsPlugin.cancel(id: citaId);
  }
}

import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/notification_service.dart';

class AlarmRingingPage extends StatelessWidget {
  final AlarmSettings settings;

  const AlarmRingingPage({super.key, required this.settings});

  void _snooze(BuildContext context, int minutes) async {
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
    
    // Extraer datos del cuerpo de la notificación original si es posible
    final title = settings.notificationSettings.title;
    final body = settings.notificationSettings.body;

    final newSettings = settings.copyWith(
      dateTime: snoozeTime,
      notificationSettings: NotificationSettings(
        title: 'POSPUESTA ($minutes min)',
        body: body,
        stopButton: 'POSPONER',
        icon: 'ic_launcher',
      ),
    );

    await Alarm.stop(settings.id);
    await Alarm.set(alarmSettings: newSettings);
    
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _stop(BuildContext context) async {
    await Alarm.stop(settings.id);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900.withOpacity(0.8),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm_on, size: 100, color: Colors.blue),
                  const SizedBox(height: 20),
                  Text(
                    '¡ALERTA DE CITA!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    settings.notificationSettings.body.replaceAll('. Toque para ver opciones.', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 40),
                  const Text('POSPONER:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildSnoozeButton(context, 15),
                      _buildSnoozeButton(context, 30),
                      _buildSnoozeButton(context, 45),
                      _buildSnoozeButton(context, 60, label: '1 Hora'),
                    ],
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => _stop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        'APAGAR ALARMA',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnoozeButton(BuildContext context, int minutes, {String? label}) {
    return SizedBox(
      width: 100,
      height: 60,
      child: OutlinedButton(
        onPressed: () => _snooze(context, minutes),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label ?? '$minutes min',
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

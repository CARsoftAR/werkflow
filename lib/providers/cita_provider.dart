import 'package:flutter/material.dart';
import '../core/database/database_service.dart';
import '../models/models.dart';
import '../core/services/service_locator.dart';
import '../core/services/notification_service.dart';

class CitaProvider extends ChangeNotifier {
  final DatabaseService _db = locator<DatabaseService>();
  final NotificationService _notifications = locator<NotificationService>();
  List<Cita> _citas = [];

  List<Cita> get citas => _citas;

  List<Cita> get pendingCitas {
    return _citas.where((c) => c.estado == 'Pendiente').toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  }

  Future<void> loadCitas() async {
    final List<Map<String, dynamic>> maps = await _db.queryAll('citas');
    _citas = maps.map((m) => Cita.fromMap(m)).toList();
    notifyListeners();
  }

  Future<int> createCita(Cita cita) async {
    final id = await _db.insert('citas', cita.toMap());
    final newCita = Cita(
      id: id,
      clienteId: cita.clienteId,
      fechaHora: cita.fechaHora,
      estado: cita.estado,
      recordatorioActivo: cita.recordatorioActivo,
      sonido: cita.sonido,
    );
    await loadCitas();
    
    if (newCita.recordatorioActivo && newCita.estado == 'Pendiente') {
      await _scheduleAlarm(newCita);
    }
    
    return id;
  }

  Future<void> updateCita(Cita cita) async {
    if (cita.id == null) return;
    await _db.update('citas', cita.toMap(), cita.id!);
    await loadCitas();
    
    if (cita.recordatorioActivo && cita.estado == 'Pendiente') {
      await _scheduleAlarm(cita);
    } else {
      await _notifications.cancelCitaNotification(cita.id!);
    }
  }

  Future<void> deleteCita(int id) async {
    await _db.delete('citas', id);
    await _notifications.cancelCitaNotification(id);
    await loadCitas();
  }

  Future<void> markAsAttended(int id) async {
    final citaMap = await _db.queryById('citas', id);
    if (citaMap != null) {
      final cita = Cita.fromMap(citaMap);
      final updatedCita = Cita(
        id: cita.id,
        clienteId: cita.clienteId,
        fechaHora: cita.fechaHora,
        estado: 'Atendida',
        recordatorioActivo: false,
        sonido: cita.sonido,
      );
      await updateCita(updatedCita);
    }
  }

  Future<void> _scheduleAlarm(Cita cita) async {
    // Get client name for the notification
    final clientMap = await _db.queryById('clientes', cita.clienteId);
    Cliente? cliente;
    if (clientMap != null) {
      cliente = Cliente.fromMap(clientMap);
    }
    await _notifications.scheduleCitaNotification(cita, cliente);
  }
}

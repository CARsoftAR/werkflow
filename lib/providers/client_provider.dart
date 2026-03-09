import 'package:flutter/material.dart';
import '../../core/database/database_service.dart';
import '../../models/models.dart';
import '../../core/services/service_locator.dart';

class ClientProvider extends ChangeNotifier {
  final DatabaseService _db = locator<DatabaseService>();
  
  List<Cliente> _clients = [];
  List<Cliente> get clients => _clients;

  Future<void> loadClients() async {
    final List<Map<String, dynamic>> maps = await _db.queryAll('clientes');
    _clients = maps.map((c) => Cliente.fromMap(c)).toList();
    notifyListeners();
  }

  Future<int> addClient(Cliente client) async {
    final id = await _db.insert('clientes', client.toMap());
    await loadClients();
    return id;
  }

  Future<void> updateClient(Cliente client) async {
    if (client.id == null) return;
    await _db.update('clientes', client.toMap(), client.id!);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _db.delete('clientes', id);
    await loadClients();
  }

  List<Cliente> searchClients(String query) {
    if (query.isEmpty) return _clients;
    return _clients.where((c) => 
      c.nombre.toLowerCase().contains(query.toLowerCase()) ||
      (c.celular?.contains(query) ?? false)
    ).toList();
  }
}

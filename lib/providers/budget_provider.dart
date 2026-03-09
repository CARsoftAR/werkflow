import 'package:flutter/material.dart';
import '../../core/database/database_service.dart';
import '../../models/models.dart';
import '../../core/services/service_locator.dart';

class BudgetProvider extends ChangeNotifier {
  final DatabaseService _db = locator<DatabaseService>();
  
  List<Presupuesto> _budgets = [];
  List<Presupuesto> get budgets => _budgets;

  double get realIncome {
    return _budgets
        .where((b) => b.estado == 'Terminada')
        .fold(0.0, (sum, b) => sum + b.totalGeneral);
  }

  double get projectedIncome {
    return _budgets
        .where((b) => b.estado == 'Aprobado')
        .fold(0.0, (sum, b) => sum + b.totalGeneral);
  }

  int get pendingBudgetsCount {
    return _budgets.where((b) => b.estado == 'Aprobado' || b.estado == 'Enviado').length;
  }

  bool get hasApproved => _budgets.any((b) => b.estado == 'Aprobado');
  bool get hasSent => _budgets.any((b) => b.estado == 'Enviado');

  int get draftsCount {
    return _budgets.where((b) => b.estado == 'Borrador').length;
  }

  bool hasBudgetForClient(int clientId) {
    return _budgets.any((b) => b.clienteId == clientId);
  }

  Future<void> loadBudgets() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('presupuestos');
    
    List<Presupuesto> tempBudgets = [];
    for (var map in maps) {
      final itemsMap = await db.query(
        'items_presupuesto', 
        where: 'presupuesto_id = ?', 
        whereArgs: [map['id']]
      );
      final items = itemsMap.map((i) => PresupuestoItem.fromMap(i)).toList();
      tempBudgets.add(Presupuesto.fromMap(map, items: items));
    }
    _budgets = tempBudgets;
    notifyListeners();
  }

  Future<int> createBudget(Presupuesto presupuesto) async {
    final db = await _db.database;
    final id = await db.transaction((txn) async {
      final id = await txn.insert('presupuestos', presupuesto.toMap());
      for (var item in presupuesto.items) {
        final itemMap = item.toMap();
        itemMap['presupuesto_id'] = id;
        await txn.insert('items_presupuesto', itemMap);
      }
      return id;
    });
    await loadBudgets();
    return id;
  }

  Future<void> updateBudget(Presupuesto presupuesto) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'presupuestos', 
        presupuesto.toMap(), 
        where: 'id = ?', 
        whereArgs: [presupuesto.id]
      );
      await txn.delete(
        'items_presupuesto', 
        where: 'presupuesto_id = ?', 
        whereArgs: [presupuesto.id]
      );
      for (var item in presupuesto.items) {
        final itemMap = item.toMap();
        itemMap['presupuesto_id'] = presupuesto.id;
        await txn.insert('items_presupuesto', itemMap);
      }
    });
    await loadBudgets();
  }

  Future<void> deleteBudget(int id) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('items_presupuesto', where: 'presupuesto_id = ?', whereArgs: [id]);
      await txn.delete('presupuestos', where: 'id = ?', whereArgs: [id]);
    });
    await loadBudgets();
  }
}

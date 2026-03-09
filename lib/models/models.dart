import 'dart:convert';

class Cliente {
  final int? id;
  final String nombre;
  final String? cuitDireccion;
  final String? celular;
  final String? notasTecnicas;

  Cliente({
    this.id,
    required this.nombre,
    this.cuitDireccion,
    this.celular,
    this.notasTecnicas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cuit_direccion': cuitDireccion,
      'celular': celular,
      'notas_tecnicas': notasTecnicas,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nombre: map['nombre'],
      cuitDireccion: map['cuit_direccion'],
      celular: map['celular'],
      notasTecnicas: map['notas_tecnicas'],
    );
  }
}

class Cita {
  final int? id;
  final int clienteId;
  final DateTime fechaHora;
  final String estado; // Pendiente, Atendida, Cancelada
  final bool recordatorioActivo;

  Cita({
    this.id,
    required this.clienteId,
    required this.fechaHora,
    required this.estado,
    this.recordatorioActivo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'fecha_hora': fechaHora.toIso8601String(),
      'estado': estado,
      'recordatorio_activo': recordatorioActivo ? 1 : 0,
    };
  }

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'],
      clienteId: map['cliente_id'],
      fechaHora: DateTime.parse(map['fecha_hora']),
      estado: map['estado'],
      recordatorioActivo: map['recordatorio_activo'] == 1,
    );
  }
}

class PresupuestoItem {
  final int? id;
  final int? presupuestoId;
  final String descripcion;
  final double cantidad;
  final double precioUnitario;

  PresupuestoItem({
    this.id,
    this.presupuestoId,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'presupuesto_id': presupuestoId,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
    };
  }

  factory PresupuestoItem.fromMap(Map<String, dynamic> map) {
    return PresupuestoItem(
      id: map['id'],
      presupuestoId: map['presupuesto_id'],
      descripcion: map['descripcion'],
      cantidad: (map['cantidad'] as num).toDouble(),
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
    );
  }
}

class Presupuesto {
  final int? id;
  final int clienteId;
  final DateTime fecha;
  final String estado; // Borrador, Enviado, Aprobado, Cobrado
  final double totalMateriales;
  final double totalManoObra;
  final double totalGeneral;
  final List<PresupuestoItem> items;

  Presupuesto({
    this.id,
    required this.clienteId,
    required this.fecha,
    required this.estado,
    this.totalMateriales = 0.0,
    this.totalManoObra = 0.0,
    this.totalGeneral = 0.0,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'fecha': fecha.toIso8601String(),
      'estado': estado,
      'total_materiales': totalMateriales,
      'total_mano_obra': totalManoObra,
      'total_general': totalGeneral,
    };
  }

  factory Presupuesto.fromMap(Map<String, dynamic> map, {List<PresupuestoItem> items = const []}) {
    return Presupuesto(
      id: map['id'],
      clienteId: map['cliente_id'],
      fecha: DateTime.parse(map['fecha']),
      estado: map['estado'],
      totalMateriales: (map['total_materiales'] as num?)?.toDouble() ?? 0.0,
      totalManoObra: (map['total_mano_obra'] as num?)?.toDouble() ?? 0.0,
      totalGeneral: (map['total_general'] as num?)?.toDouble() ?? 0.0,
      items: items,
    );
  }
}

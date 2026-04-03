import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/cita_provider.dart';
import '../../models/models.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';
import '../clients/new_client_page.dart';
import 'package:flutter/services.dart';

class NewCitaPage extends StatefulWidget {
  final Cita? cita;
  const NewCitaPage({super.key, this.cita});

  @override
  State<NewCitaPage> createState() => _NewCitaPageState();
}

class _NewCitaPageState extends State<NewCitaPage> {
  int? _selectedClientId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _estado = 'Pendiente';
  String _selectedSonido = 'assets/alarma_1.mp3';

  final List<Map<String, String>> _sonidosDisponibles = [
    {'nombre': 'Classic (App)', 'path': 'assets/alarma_1.mp3'},
    {'nombre': 'Gatito (App)', 'path': 'assets/gatito.mp3'},
    {'nombre': 'Predeterminado (Sistema)', 'path': 'default'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cita != null) {
      _selectedClientId = widget.cita!.clienteId;
      _selectedDate = widget.cita!.fechaHora;
      _selectedTime = TimeOfDay.fromDateTime(widget.cita!.fechaHora);
      _estado = widget.cita!.estado;
      _selectedSonido = widget.cita!.sonido ?? 'assets/alarma_1.mp3';
      
      // Asegurarse de que el sonido guardado esté en la lista para evitar errores del Dropdown
      bool exists = _sonidosDisponibles.any((s) => s['path'] == _selectedSonido);
      if (!exists) {
        _sonidosDisponibles.add({
          'nombre': 'Sonido guardado',
          'path': _selectedSonido,
        });
      }
    }
    _loadSystemSounds();
  }

  static const platform = MethodChannel('com.werkflow.alarms/sounds');

  Future<void> _loadSystemSounds() async {
    try {
      final List<dynamic>? result = await platform.invokeMethod('getSystemAlarms');
      if (mounted && result != null && result.isNotEmpty) {
        setState(() {
          for (var r in result) {
            try {
              final map = Map<String, String>.from(r as Map);
              if (!_sonidosDisponibles.any((s) => s['path'] == map['path'])) {
                _sonidosDisponibles.add(map);
              }
            } catch (_) {}
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading system sounds: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(widget.cita == null ? 'NUEVA CITA' : 'EDITAR CITA'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('DATOS DE LA VISITA'),
            const SizedBox(height: 16),
            _buildGlassInputCard(
              child: Column(
                children: [
                   _buildClientDropdown(context),
                   const Divider(height: 1),
                   _buildDatePickerRow(context),
                   const Divider(height: 1),
                   _buildTimePickerRow(context),
                   const Divider(height: 1),
                   _buildSoundPickerRow(context),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('ESTADO'),
            const SizedBox(height: 16),
            _buildGlassStatusCard(),
            const SizedBox(height: 40),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: colorScheme.primary.withOpacity(0.5), // Consistent with Dashboard
      ),
    );
  }

  Widget _buildGlassInputCard({required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.1,
      backgroundColor: colorScheme.surface,
      child: child,
    );
  }

  Widget _buildClientDropdown(BuildContext context) {
    final clients = context.watch<ClientProvider>().clients;
    
    return Row(
      children: [
        const Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const Spacer(),
        if (clients.isEmpty)
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewClientPage())),
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('CREAR +', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          )
        else
          DropdownButton<int>(
            value: _selectedClientId ?? (clients.isNotEmpty ? clients.first.id : null),
            items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
            onChanged: (val) => setState(() => _selectedClientId = val),
            underline: const SizedBox(),
            hint: const Text('Seleccionar'),
          ),
      ],
    );
  }

  Widget _buildDatePickerRow(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            Text(_selectedTime.format(context), 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    platform.invokeMethod('stopPreview');
    super.dispose();
  }

  Widget _buildSoundPickerRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sonido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.play_circle_fill, color: Colors.blue, size: 28),
                onPressed: () => platform.invokeMethod('playPreview', {'uri': _selectedSonido}),
              ),
              DropdownButton<String>(
                value: _selectedSonido,
                items: _sonidosDisponibles.map((s) => DropdownMenuItem(
                  value: s['path'],
                  child: SizedBox(
                    width: 120,
                    child: Text(s['nombre']!, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                  ),
                )).toList(),
                onChanged: (val) {
                  setState(() => _selectedSonido = val!);
                  platform.invokeMethod('playPreview', {'uri': val});
                },
                underline: const SizedBox(),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatusCard() {
    return _buildGlassInputCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Estado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          DropdownButton<String>(
            value: _estado,
            items: ['Pendiente', 'Atendida', 'Cancelada']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => setState(() => _estado = val!),
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_selectedClientId == null) {
          final clients = context.read<ClientProvider>().clients;
          if (clients.isNotEmpty) {
             _selectedClientId = clients.first.id;
          } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crea un cliente primero')));
             return;
          }
        }

        final DateTime fullDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final cita = Cita(
          id: widget.cita?.id,
          clienteId: _selectedClientId!,
          fechaHora: fullDateTime,
          estado: _estado,
          recordatorioActivo: true,
          sonido: _selectedSonido,
        );

        try {
          if (widget.cita == null) {
            await context.read<CitaProvider>().createCita(cita);
          } else {
            await context.read<CitaProvider>().updateCita(cita);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita agendada correctamente')));
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56), // Smaller
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8, // Added elevation for depth
        shadowColor: AppColors.primary.withOpacity(0.4),
      ),
      child: Text(
        widget.cita == null ? 'AGENDAR CITA' : 'ACTUALIZAR CITA', 
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
      ),
    );
  }
}

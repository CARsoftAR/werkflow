import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/cita_provider.dart';
import '../../models/models.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';
import '../clients/new_client_page.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.cita != null) {
      _selectedClientId = widget.cita!.clienteId;
      _selectedDate = widget.cita!.fechaHora;
      _selectedTime = TimeOfDay.fromDateTime(widget.cita!.fechaHora);
      _estado = widget.cita!.estado;
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Colors.grey.shade600,
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
        minimumSize: const Size(double.infinity, 64),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      child: Text(
        widget.cita == null ? 'AGENDAR CITA' : 'ACTUALIZAR CITA', 
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
      ),
    );
  }
}

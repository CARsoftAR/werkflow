import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';
import '../../models/models.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';

class NewClientPage extends StatefulWidget {
  final Cliente? client;
  const NewClientPage({super.key, this.client});

  @override
  State<NewClientPage> createState() => _NewClientPageState();
}

class _NewClientPageState extends State<NewClientPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _celularController;
  late TextEditingController _direccionController;
  late TextEditingController _notasController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.client?.nombre);
    _celularController = TextEditingController(text: widget.client?.celular);
    _direccionController = TextEditingController(text: widget.client?.cuitDireccion);
    _notasController = TextEditingController(text: widget.client?.notasTecnicas);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _celularController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(widget.client == null ? 'NUEVO CLIENTE' : 'EDITAR CLIENTE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('INFORMACIÓN PERSONAL'),
              const SizedBox(height: 16),
              _buildGlassInputCard(
                child: Column(
                  children: [
                    _buildTextField(_nombreController, 'Nombre y Apellido', Icons.person_rounded, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const Divider(height: 1),
                    _buildTextField(_celularController, 'Celular (WhatsApp)', Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('DATOS DE FACTURACIÓN / OBRA'),
              const SizedBox(height: 16),
              _buildGlassInputCard(
                child: _buildTextField(_direccionController, 'CUIT / Dirección', Icons.location_on_rounded),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('NOTAS TÉCNICAS'),
              const SizedBox(height: 16),
              _buildGlassInputCard(
                child: _buildTextField(_notasController, 'Equipos, accesos, etc.', Icons.sticky_note_2_rounded, maxLines: 4),
              ),
              const SizedBox(height: 48),
              _buildSaveButton(context),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.1,
      backgroundColor: colorScheme.surface,
      child: child,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        floatingLabelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 14),
        filled: false,
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final client = Cliente(
            id: widget.client?.id,
            nombre: _nombreController.text,
            celular: _celularController.text,
            cuitDireccion: _direccionController.text,
            notasTecnicas: _notasController.text,
          );
          if (widget.client == null) {
            await context.read<ClientProvider>().addClient(client);
          } else {
            await context.read<ClientProvider>().updateClient(client);
          }
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56), // Slightly smaller
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8, // Added elevation for depth
        shadowColor: AppColors.primary.withOpacity(0.4),
      ),
      child: Text(
        widget.client == null ? 'REGISTRAR CLIENTE' : 'ACTUALIZAR DATOS', 
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
      ),
    );
  }
}

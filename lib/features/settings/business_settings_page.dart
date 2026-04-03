import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/business_provider.dart';
import '../../models/models.dart';
import '../../core/theme/app_theme.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _footerTitleController;
  late TextEditingController _footerTextController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final info = context.read<BusinessProvider>().businessInfo;
    _nameController = TextEditingController(text: info?.name);
    _phoneController = TextEditingController(text: info?.phone);
    _emailController = TextEditingController(text: info?.email);
    _websiteController = TextEditingController(text: info?.website);
    _addressController = TextEditingController(text: info?.address);
    _footerTitleController = TextEditingController(text: info?.footerTitle);
    _footerTextController = TextEditingController(text: info?.footerText);
    _imagePath = info?.headerImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _footerTitleController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final info = BusinessInfo(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
        address: _addressController.text,
        footerTitle: _footerTitleController.text,
        footerText: _footerTextController.text,
        headerImagePath: _imagePath,
      );
      await context.read<BusinessProvider>().saveBusinessInfo(info);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada')),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá el Nombre y el Celular para guardar'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIGURACIÓN NEGOCIO'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Imagen de Cabecera'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imagePath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Seleccionar Imagen', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Datos Generales'),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Nombre del Comercio', Icons.business_rounded, required: true),
              _buildTextField(_phoneController, 'Celular / WhatsApp', Icons.phone_android_rounded, required: true),
              _buildTextField(_emailController, 'Email', Icons.email_outlined),
              _buildTextField(_websiteController, 'Página Web', Icons.language_rounded),
              _buildTextField(_addressController, 'Dirección Física', Icons.location_on_outlined),
              const SizedBox(height: 32),
              _buildSectionTitle('Pie de Página (Términos)'),
              const SizedBox(height: 16),
              _buildTextField(_footerTitleController, 'Título del Pie', Icons.title_rounded),
              _buildTextField(_footerTextController, 'Texto Legal / Condiciones', Icons.description_outlined, maxLines: 4),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('GUARDAR CONFIGURACIÓN', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2, color: AppColors.primary),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Campo requerido';
          }
          return null;
        },
      ),
    );
  }
}

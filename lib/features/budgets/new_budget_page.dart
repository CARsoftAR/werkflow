import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/client_provider.dart';
import '../clients/new_client_page.dart';
import '../../core/services/pdf_service.dart';
import '../../providers/business_provider.dart';

class NewBudgetPage extends StatefulWidget {
  final Presupuesto? budget;
  final int? initialClientId;
  const NewBudgetPage({super.key, this.budget, this.initialClientId});

  @override
  State<NewBudgetPage> createState() => _NewBudgetPageState();
}

class _NewBudgetPageState extends State<NewBudgetPage> {
  final _items = <PresupuestoItem>[];
  late String _selectedStatus;
  int? _selectedClientId;

  final _descController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  double get totalMateriales => _items.fold(0, (sum, i) => sum + i.subtotal);
  double get totalGeneral => totalMateriales; // For now

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.budget?.estado ?? 'Borrador';
    _selectedClientId = widget.budget?.clienteId ?? widget.initialClientId;
    if (widget.budget != null) {
      _items.addAll(widget.budget!.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.budget == null ? 'NUEVO PRESUPUESTO' : 'EDITAR PRESUPUESTO'
        ),
        actions: [
          if (widget.budget != null || _items.isNotEmpty)
            IconButton(
              onPressed: () async {
                final business = context.read<BusinessProvider>().businessInfo;
                final clients = context.read<ClientProvider>().clients;
                
                if (clients.isEmpty || _selectedClientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleccioná un cliente para el PDF')),
                  );
                  return;
                }
                
                final client = clients.firstWhere((c) => c.id == _selectedClientId, orElse: () => clients.first);
                
                final tempBudget = Presupuesto(
                  id: widget.budget?.id,
                  clienteId: _selectedClientId ?? 0,
                  fecha: widget.budget?.fecha ?? DateTime.now(),
                  estado: _selectedStatus,
                  totalGeneral: totalGeneral,
                  items: _items,
                );
                
                await PdfService.generateAndPrintBudget(tempBudget, client, business);
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('INFORMACIÓN GENERAL'),
            const SizedBox(height: 16),
            _buildGlassInputCard(
              child: Column(
                children: [
                  _buildDropdown('Estado', ['Borrador', 'Enviado', 'Aprobado', 'Terminada', 'Cancelada'], (val) => setState(() => _selectedStatus = val!)),
                  const Divider(height: 1),
                  _buildClientDropdown(context),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('ÍTEMS DEL TRABAJO'),
            const SizedBox(height: 16),
            ..._items.asMap().entries.map((entry) => _buildItemCard(entry.value, entry.key)),
            _buildAddItemCard(context),
            const SizedBox(height: 32),
            _buildSummaryCard(),
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
      padding: const EdgeInsets.all(20),
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
            label: const Text('CREAR CLIENTE +', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildDropdown(String label, List<String> options, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const Spacer(),
        DropdownButton<String>(
          value: _selectedStatus,
          items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildItemCard(PresupuestoItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showItemEditorDialog(context, item: item, index: index),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.descripcion, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('${item.cantidad} x \$${item.precioUnitario.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Editar', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddItemCard(BuildContext context) {
    return InkWell(
      onTap: () => _showItemEditorDialog(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2, style: BorderStyle.none),
          borderRadius: BorderRadius.circular(24),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text('Agregar Ítem', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showItemEditorDialog(BuildContext context, {PresupuestoItem? item, int? index}) {
    if (item != null) {
      _descController.text = item.descripcion;
      _qtyController.text = item.cantidad.toString();
      _priceController.text = item.precioUnitario.toString();
    } else {
      _descController.clear();
      _qtyController.clear();
      _priceController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(item == null ? 'NUEVO ÍTEM' : 'EDITAR ÍTEM', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descController, 
              decoration: const InputDecoration(labelText: 'Descripción', hintText: 'Ej: Mano de obra'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _qtyController, decoration: const InputDecoration(labelText: 'Cant.'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio U.'), keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          if (item != null)
            TextButton(
              onPressed: () {
                setState(() => _items.removeAt(index!));
                Navigator.pop(context);
              },
              child: const Text('ELIMINAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              if (_descController.text.isEmpty || _qtyController.text.isEmpty || _priceController.text.isEmpty) return;
              
              setState(() {
                final newItem = PresupuestoItem(
                  descripcion: _descController.text,
                  cantidad: double.parse(_qtyController.text),
                  precioUnitario: double.parse(_priceController.text),
                );
                
                if (index != null) {
                  _items[index] = newItem;
                } else {
                  _items.add(newItem);
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(item == null ? 'AGREGAR' : 'GUARDAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(28),
      backgroundColor: Colors.white.withOpacity(0.95),
      child: Column(
        children: [
          _buildSummaryRow('Materiales + Mano de Obra', '\$ ${totalMateriales.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildSummaryRow('TOTAL ESTIMADO', '\$ ${totalGeneral.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label, 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, 
              fontSize: isBold ? 14 : 12, 
              color: isBold ? Colors.black : Colors.grey,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: isBold ? 20 : 16, 
            color: isBold ? AppColors.primary : Colors.black,
          ),
        ),
      ],
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, selecciona o crea un cliente')),
            );
            return;
          }
        }

        if (_items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agrega al menos un ítem al presupuesto')),
          );
          return;
        }

        try {
          final p = Presupuesto(
            id: widget.budget?.id,
            clienteId: _selectedClientId!,
            fecha: widget.budget?.fecha ?? DateTime.now(),
            estado: _selectedStatus,
            totalGeneral: totalGeneral,
            items: _items,
          );
          
          if (widget.budget == null) {
            await context.read<BudgetProvider>().createBudget(p);
          } else {
            await context.read<BudgetProvider>().updateBudget(p);
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Presupuesto guardado correctamente')),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar: $e')),
            );
          }
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
        widget.budget == null ? 'GUARDAR PRESUPUESTO' : 'ACTUALIZAR CAMBIOS', 
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
      ),
    );
  }
}

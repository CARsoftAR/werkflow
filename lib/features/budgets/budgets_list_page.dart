import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/client_provider.dart';
import '../../models/models.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';
import 'new_budget_page.dart';
import '../settings/business_settings_page.dart';
import '../../core/services/pdf_service.dart';
import '../../providers/business_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class BudgetsListPage extends StatefulWidget {
  const BudgetsListPage({super.key});

  @override
  State<BudgetsListPage> createState() => _BudgetsListPageState();
}

class _BudgetsListPageState extends State<BudgetsListPage> {
  static const _whatsappChannel = MethodChannel('com.werkflow.whatsapp/direct');

  Future<void> _shareDirectlyToWhatsApp(String phone, String filePath, String text) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    // Si tiene 10 dígitos (ej: 1122334455), agregamos el prefijo de Argentina 549
    if (cleanPhone.length == 10) {
      cleanPhone = '549$cleanPhone';
    } 
    // Si tiene 11 dígitos y empieza con 15, es formato local, lo corregimos
    else if (cleanPhone.length == 11 && cleanPhone.startsWith('15')) {
      cleanPhone = '549${cleanPhone.substring(2)}';
    }
    // Si ya empieza con 54 pero le falta el 9 para celular
    else if (cleanPhone.startsWith('54') && cleanPhone.length == 12 && !cleanPhone.startsWith('549')) {
      cleanPhone = '549${cleanPhone.substring(2)}';
    }

    try {
      await _whatsappChannel.invokeMethod('sendPdfToWhatsApp', {
        'phone': cleanPhone,
        'filePath': filePath,
        'text': text,
      });
    } catch (e) {
      debugPrint("Native WhatsApp failed: $e");
      // Fallback
      await Share.shareXFiles(
        [XFile(filePath)],
        text: text,
      );
    }
  }

  String _activeFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Borrador', 'Enviado', 'Aprobado', 'Terminada', 'Cancelada'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetProvider = context.watch<BudgetProvider>();
    
    final filteredBudgets = _activeFilter == 'Todos' 
      ? budgetProvider.budgets 
      : budgetProvider.budgets.where((b) => b.estado == _activeFilter).toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'PRESUPUESTOS',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.5),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const BusinessSettingsPage())
            ),
            icon: const Icon(Icons.settings_suggest_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: filteredBudgets.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 120),
                    itemCount: filteredBudgets.length,
                    itemBuilder: (context, index) {
                      final budget = filteredBudgets[index];
                      return _buildBudgetCard(context, budget);
                    },
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterBar() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              labelStyle: TextStyle(
                fontSize: 12, 
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4)
              ),
              selected: isSelected,
              onSelected: (val) => setState(() => _activeFilter = filter),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), 
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05))
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'Sin presupuestos aún',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea uno nuevo para empezar a gestionar.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Presupuesto budget) {
    Color statusColor;
    switch (budget.estado) {
      case 'Aprobado': statusColor = Colors.green; break;
      case 'Enviado': statusColor = Colors.red; break; // User request: Red for Sent
      case 'Terminada': statusColor = Colors.teal; break;
      case 'Cancelada': statusColor = Colors.grey; break;
      default: statusColor = Colors.blue;
    }

    final clients = context.watch<ClientProvider>().clients;
    final client = clients.cast<Cliente?>().firstWhere((c) => c?.id == budget.clienteId, orElse: () => null);
    final clientName = client?.nombre ?? "Cliente #${budget.clienteId}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(budget.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        onDismissed: (_) {
          context.read<BudgetProvider>().deleteBudget(budget.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Presupuesto eliminado')),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              try {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => NewBudgetPage(budget: budget))
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No pudimos abrir el presupuesto: $e')),
                );
              }
            },
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          budget.estado.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                      Text(
                        '${budget.fecha.day}/${budget.fecha.month}/${budget.fecha.year}',
                        style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.3), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    budget.items.isNotEmpty ? budget.items.first.descripcion : 'Trabajo Técnico',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.person_rounded, size: 14, color: AppColors.textDark.withOpacity(0.3)),
                      const SizedBox(width: 6),
                      Text(
                        clientName,
                        style: TextStyle(color: AppColors.textDark.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL', 
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textDark.withOpacity(0.3))
                          ),
                          Text(
                            '\$ ${budget.totalGeneral.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          if (client != null) {
                            showDialog(
                              context: context, 
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator())
                            );
                            try {
                              final business = context.read<BusinessProvider>().businessInfo;
                              final path = await PdfService.generateBudgetFile(budget, client, business);
                              
                              if (mounted) Navigator.pop(context);

                              final phone = client.celular ?? '';
                              final text = 'Presupuesto de Ñomin Agenda para ${client.nombre}';

                              if (phone.isNotEmpty) {
                                await _shareDirectlyToWhatsApp(phone, path, text);
                              } else {
                                await Share.shareXFiles(
                                  [XFile(path)],
                                  text: text,
                                  subject: 'Presupuesto ${budget.id}',
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error: Generá primero el PDF antes de enviar'), backgroundColor: Colors.red),
                            );
                          }
                        },
                        icon: const Icon(Icons.chat_rounded, color: Colors.green),
                      ),

                      IconButton(
                        onPressed: () async {
                          final business = context.read<BusinessProvider>().businessInfo;
                          if (client != null) {
                            showDialog(
                              context: context, 
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator())
                            );
                            try {
                              await PdfService.generateAndPrintBudget(budget, client, business);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
                            } finally {
                              if (mounted) Navigator.pop(context);
                            }
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                      ),

                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.textDark.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDark.withOpacity(0.3)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

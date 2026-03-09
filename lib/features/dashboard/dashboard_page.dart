import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/flowy_card.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/client_provider.dart';
import '../budgets/new_budget_page.dart';
import '../budgets/budgets_list_page.dart';
import '../clients/clients_list_page.dart';
import '../clients/new_client_page.dart';
import '../citas/citas_list_page.dart';
import '../citas/new_cita_page.dart';
import '../../models/models.dart';
import '../../providers/cita_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildCompactAppBar(context, colorScheme),
      body: Stack(
        children: [
          // Elegant Background
          _buildProfessionalBackground(colorScheme),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // 1. Priority: The Event (Not the clock)
                  _buildNextJobCard(context, colorScheme),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Business Bento: Money & Agenda
                  _buildBusinessBentoGrid(context),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'HERRAMIENTAS DE GESTIÓN',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: colorScheme.onBackground.withOpacity(0.4),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 3. Functional Actions
                  _buildFunctionalActions(context, colorScheme),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Floating Action - Professional Tool style
          Positioned(
            bottom: 32,
            right: 24,
            child: _buildBusinessFAB(context, colorScheme),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCompactAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WERKFLOW',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 26,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
          Text(
            'Gestión de Servicios Técnicos',
            style: TextStyle(
              fontSize: 12, 
              color: Colors.white.withOpacity(0.4), 
              fontWeight: FontWeight.bold, 
              letterSpacing: 0.5
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: StreamBuilder(
            stream: Stream.periodic(const Duration(minutes: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return Text(
                '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNextJobCard(BuildContext context, ColorScheme colorScheme) {
    final budgets = context.watch<BudgetProvider>().budgets;
    final pendingCitas = context.watch<CitaProvider>().pendingCitas;
    final clients = context.watch<ClientProvider>().clients;

    // Prioritize Appointments (Citas) first, then Approved budgets
    if (pendingCitas.isNotEmpty) {
      final cita = pendingCitas.first;
      final client = clients.cast<Cliente?>().firstWhere((c) => c?.id == cita.clienteId, orElse: () => null);
      final clientName = client?.nombre ?? "Cliente #${cita.clienteId}";

      return _buildEventCard(
        context, 
        colorScheme, 
        title: 'VISITA AL DOMICILIO',
        mainText: clientName,
        subText: 'Hora: ${TimeOfDay.fromDateTime(cita.fechaHora).format(context)}',
        dateText: '${cita.fechaHora.day}/${cita.fechaHora.month}',
        icon: Icons.home_repair_service_rounded,
        iconColor: Colors.orange,
        onCall: () {},
        onMap: () {},
      );
    }

    final nextBudget = budgets
        .where((b) => b.estado == 'Aprobado')
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    if (nextBudget.isNotEmpty) {
      final budget = nextBudget.first;
      final client = clients.cast<Cliente?>().firstWhere((c) => c?.id == budget.clienteId, orElse: () => null);
      final clientName = client?.nombre ?? "Cliente #${budget.clienteId}";

      return _buildEventCard(
        context, 
        colorScheme, 
        title: 'TRABAJO APROBADO',
        mainText: budget.items.isNotEmpty ? budget.items.first.descripcion : 'Trabajo Técnico',
        subText: clientName,
        dateText: '${budget.fecha.day}/${budget.fecha.month}',
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green,
        onCall: () {},
        onMap: () {},
        price: budget.totalGeneral,
      );
    }

    return _buildEmptyJobCard(context, colorScheme);
  }

  Widget _buildEventCard(
    BuildContext context, 
    ColorScheme colorScheme, {
    required String title,
    required String mainText,
    required String subText,
    required String dateText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onCall,
    required VoidCallback onMap,
    double? price,
  }) {
    return FlowyCard(
      title: mainText,
      icon: icon,
      gradient: AppColors.rockGradient,
      height: 220,
      onTap: () {},
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(subText, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(dateText, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
      trailing: price != null 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '\$${price.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          )
        : null,
    );
  }

  Widget _buildEmptyJobCard(BuildContext context, ColorScheme colorScheme) {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      borderRadius: BorderRadius.circular(32),
      opacity: 0.4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today_rounded, size: 40, color: colorScheme.primary),
          ),
          const SizedBox(height: 24),
          const Text('No hay trabajos activos', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            'Tu agenda aparecerá aquí cuando tengas visitas o trabajos programados.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalBackground(ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
              radius: 200, 
              backgroundColor: AppColors.primary.withOpacity(0.08)
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: CircleAvatar(
              radius: 150, 
              backgroundColor: AppColors.secondary.withOpacity(0.05)
            ),
          ),
          // Subtle Grain/Gradient overlay for deeper look
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  AppColors.primary.withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextJobCard_Old(BuildContext context, ColorScheme colorScheme) {
    return GlassCard(
      blur: 20,
      opacity: 0.7,
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PRÓXIMO TRABAJO',
                  style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
              const Text('18:30 HS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          // Main Title: The Job & Client
          const Text(
            'Instalación Panel - Juan Pérez',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          // Direction and Data
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Av. Corrientes 1234, CABA', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              const Text('\$ 45.000', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              const Text('Presupuesto Aprobado', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 32),
          // Quick Business Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text('Llamar Cliente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.map_rounded),
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessBentoGrid(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    return Row(
      children: [
        Expanded(
          child: FlowyCard(
            height: 140,
            title: budgetProvider.realIncome >= 1000 
                ? '\$ ${(budgetProvider.realIncome / 1000).toStringAsFixed(1)}k' 
                : '\$ ${budgetProvider.realIncome.toStringAsFixed(0)}',
            subtitle: Text('Ingresos Reales', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold)),
            icon: Icons.auto_graph_rounded,
            gradient: AppColors.jazzGradient,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FlowyCard(
            height: 140,
            title: '${context.watch<ClientProvider>().clients.length}',
            subtitle: Text('Clientes Activos', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold)),
            icon: Icons.people_alt_rounded,
            gradient: AppColors.popGradient,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionalActions(BuildContext context, ColorScheme colorScheme) {
    final actions = [
      {'icon': Icons.calendar_month_rounded, 'label': 'Agenda', 'color': Colors.orange},
      {'icon': Icons.description_rounded, 'label': 'Presupuestos', 'color': Colors.teal},
      {'icon': Icons.person_add_rounded, 'label': 'Clientes', 'color': colorScheme.primary},
      {'icon': Icons.payments_rounded, 'label': 'Finanzas', 'color': Colors.green},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) => _buildToolCard(context, action)).toList(),
    );
  }

  Widget _buildToolCard(BuildContext context, Map<String, dynamic> action) {
    final width = (MediaQuery.of(context).size.width - 56) / 2;
    final budgetProvider = context.watch<BudgetProvider>();
    final showBadge = action['label'] == 'Presupuestos' && budgetProvider.pendingBudgetsCount > 0;

    // Different gradients for tools
    List<Color> getGradient() {
      switch (action['label']) {
        case 'Agenda': return AppColors.rockGradient;
        case 'Presupuestos': return AppColors.popGradient;
        case 'Clientes': return AppColors.jazzGradient;
        default: return AppColors.lofiGradient;
      }
    }

    return FlowyCard(
      width: width,
      height: 120,
      title: action['label'] as String,
      icon: action['icon'] as IconData,
      gradient: getGradient(),
      onTap: () {
        if (action['label'] == 'Presupuestos') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetsListPage()));
        } else if (action['label'] == 'Clientes') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsListPage()));
        } else if (action['label'] == 'Agenda') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CitasListPage()));
        }
      },
      trailing: showBadge 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${budgetProvider.pendingBudgetsCount}',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        : null,
    );
  }

  Widget _buildBusinessFAB(BuildContext context, ColorScheme colorScheme) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
             // Show menu to choose what to create
             showModalBottomSheet(
               context: context,
               backgroundColor: Colors.transparent,
               builder: (context) => _buildFABMenu(context, colorScheme),
             );
          },
          customBorder: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 36, color: Colors.white),
        ),
      ),
    );
  }
  Widget _buildFABMenu(BuildContext context, ColorScheme colorScheme) {
    return GlassCard(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuOption(context, Icons.event_rounded, 'Agendar Visita', Colors.orange, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewCitaPage()));
          }),
          const SizedBox(height: 16),
          _buildMenuOption(context, Icons.person_add_rounded, 'Nuevo Cliente', colorScheme.primary, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewClientPage()));
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}

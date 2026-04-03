import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/client_provider.dart';
import '../budgets/budgets_list_page.dart';
import '../clients/clients_list_page.dart';
import '../citas/citas_list_page.dart';
import '../../models/models.dart';
import '../../providers/cita_provider.dart';
import '../budgets/new_budget_page.dart';
import '../clients/new_client_page.dart';
import '../citas/new_cita_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildDynamicBackground(colorScheme),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildCustomAppBar(context, colorScheme),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('PRÓXIMO TRABAJO', colorScheme),
                  const SizedBox(height: 16),
                  _buildNextJobCard(context, colorScheme),
                  
                  const SizedBox(height: 40),
                  
                  _buildSectionHeader('RENDIMIENTO', colorScheme),
                  const SizedBox(height: 16),
                  _buildBusinessBentoGrid(context, colorScheme),
                  
                  const SizedBox(height: 40),
                  
                  _buildSectionHeader('GESTIÓN', colorScheme),
                  const SizedBox(height: 16),
                  _buildFunctionalActions(context, colorScheme),
                  
                  const SizedBox(height: 120), 
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 32,
            right: 24,
            child: _buildBusinessFAB(context, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: colorScheme.primary.withOpacity(0.5), // More red presence
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'WERKFLOW',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: -1.5,
                color: colorScheme.onBackground,
              ),
            ),
            Text(
              'Control total de servicios',
              style: TextStyle(
                fontSize: 12, 
                color: colorScheme.primary.withOpacity(0.8), // Vibrante, no apagado
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        _buildGlassClockIndicator(colorScheme),
      ],
    );
  }

  Widget _buildGlassClockIndicator(ColorScheme colorScheme) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.05,
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(minutes: 1)),
        builder: (context, snapshot) {
          final now = DateTime.now();
          return Text(
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: colorScheme.onSurface),
          );
        },
      ),
    );
  }

  Widget _buildDynamicBackground(ColorScheme colorScheme) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -100,
            child: _buildGlowOrb(300, colorScheme.primary.withOpacity(0.04)),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: _buildGlowOrb(250, colorScheme.secondary.withOpacity(0.03)),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildNextJobCard(BuildContext context, ColorScheme colorScheme) {
    final pendingCitas = context.watch<CitaProvider>().pendingCitas;
    final clients = context.watch<ClientProvider>().clients;
    final budgets = context.watch<BudgetProvider>().budgets;

    if (pendingCitas.isNotEmpty) {
      final cita = pendingCitas.first;
      final client = clients.cast<Cliente?>().firstWhere((c) => c?.id == cita.clienteId, orElse: () => null);
      final clientName = client?.nombre ?? "Cliente #${cita.clienteId}";

      return _buildEventCard(
        context, 
        colorScheme, 
        badge: 'CITA PENDIENTE',
        mainText: clientName,
        subText: 'Hora: ${TimeOfDay.fromDateTime(cita.fechaHora).format(context)}',
        dateText: '${cita.fechaHora.day}/${cita.fechaHora.month}',
        icon: Icons.event_available_rounded,
        iconColor: colorScheme.secondary,
        onCall: () {},
        onMap: () {},
      );
    }

    final approvedBudgets = budgets
        .where((b) => b.estado == 'Aprobado')
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    if (approvedBudgets.isNotEmpty) {
      final budget = approvedBudgets.first;
      final client = clients.cast<Cliente?>().firstWhere((c) => c?.id == budget.clienteId, orElse: () => null);
      final clientName = client?.nombre ?? "Cliente #${budget.clienteId}";

      return _buildEventCard(
        context, 
        colorScheme, 
        badge: 'TRABAJO APROBADO',
        mainText: clientName,
        subText: budget.items.isNotEmpty ? budget.items.first.descripcion : 'Servicio Técnico',
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
    required String badge,
    required String mainText,
    required String subText,
    required String dateText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onCall,
    required VoidCallback onMap,
    double? price,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: BorderRadius.circular(32),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      badge,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (price != null)
                Text(
                   '\$${price.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colorScheme.onSurface),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            mainText,
            style: TextStyle(
              fontSize: 26, 
              fontWeight: FontWeight.w900, 
              letterSpacing: -1,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_searching_rounded, size: 14, color: colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                subText,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                dateText,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildModernButton(
                  context, 
                  'Llamar', 
                  Icons.call_rounded, 
                  colorScheme.primary, 
                  onCall
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernButton(
                  context, 
                  'Ver Mapa', 
                  Icons.map_rounded, 
                  colorScheme.surface, 
                  onMap,
                  isSecondary: true
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap, {bool isSecondary = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48, // Un poco más chico que 54
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: !isSecondary ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withRed((color.red + 30).clamp(0, 255)), // Top edge shine
              color,
            ],
          ) : null,
          color: isSecondary ? Colors.white : null,
          border: isSecondary ? Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1.5) : null,
          boxShadow: [
            if (!isSecondary) ...[
              // Modern soft glow
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              // Intense depth bottom border
              BoxShadow(
                color: color.withRed((color.red - 50).clamp(0, 255)).withOpacity(0.8),
                blurRadius: 0,
                offset: const Offset(0, 3), // Visual depth
              ),
            ] else 
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSecondary ? colorScheme.primary : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                color: isSecondary ? colorScheme.primary : Colors.white, 
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyJobCard(BuildContext context, ColorScheme colorScheme) {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      borderRadius: BorderRadius.circular(32),
      opacity: 0.05,
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
          Text('No hay trabajos hoy', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Text(
            'Tu agenda aparecerá aquí cuando tengas visitas programadas.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessBentoGrid(BuildContext context, ColorScheme colorScheme) {
    final budgetProvider = context.watch<BudgetProvider>();
    final clientsCount = context.watch<ClientProvider>().clients.length;

    return Column(
      children: [
        // Main Revenue Card
        _buildStatCard(
          title: budgetProvider.totalProjectedIncome >= 1000 
              ? '\$${(budgetProvider.totalProjectedIncome / 1000).toStringAsFixed(1)}k' 
              : '\$${budgetProvider.totalProjectedIncome.toStringAsFixed(0)}',
          subtitle: 'Proyectado Total',
          label: 'RECAUDACIÓN ESTIMADA',
          icon: Icons.payments_rounded,
          color: AppColors.primary,
          onSurface: colorScheme.onSurface,
          isMain: true,
          extraContent: Row(
            children: [
              _buildMiniIndicator(
                'Cobrado: \$${budgetProvider.realIncome.toStringAsFixed(0)}', 
                Colors.green,
                Icons.check_circle_outline
              ),
              const SizedBox(width: 12),
              _buildMiniIndicator(
                'Pendiente: \$${budgetProvider.projectedIncome.toStringAsFixed(0)}', 
                Colors.orange,
                Icons.timer_outlined
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '${budgetProvider.conversionRate.toStringAsFixed(0)}%',
                subtitle: 'Conversión',
                label: 'EFECTIVIDAD',
                icon: Icons.bolt_rounded,
                color: Colors.amber,
                onSurface: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: '$clientsCount',
                subtitle: 'Clientes',
                label: 'CARTERA',
                icon: Icons.people_alt_rounded,
                color: Colors.blue,
                onSurface: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '${budgetProvider.approvedBudgetsCount}',
                subtitle: 'Aprobados',
                label: 'POR EJECUTAR',
                icon: Icons.assignment_turned_in_rounded,
                color: Colors.teal,
                onSurface: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: '${budgetProvider.pendingBudgetsCount}',
                subtitle: 'Enviados',
                label: 'SIN RESPUESTA',
                icon: Icons.send_rounded,
                color: AppColors.accent,
                onSurface: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniIndicator(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title, 
    required String subtitle, 
    required String label,
    required IconData icon, 
    required Color color, 
    required Color onSurface,
    bool isMain = false,
    Widget? extraContent,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(isMain ? 32 : 24),
      borderRadius: BorderRadius.circular(32),
      opacity: isMain ? 0.08 : 0.04,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.5, 
                  color: color.withOpacity(0.6)
                ),
              ),
              Icon(icon, color: color.withOpacity(0.3), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isMain ? 42 : 28, 
              fontWeight: FontWeight.w900, 
              color: onSurface,
              letterSpacing: -1,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: onSurface.withOpacity(0.4)
            ),
          ),
          if (extraContent != null) ...[
            const SizedBox(height: 20),
            extraContent,
          ],
        ],
      ),
    );
  }

  Widget _buildFunctionalActions(BuildContext context, ColorScheme colorScheme) {
    final actions = [
      {'icon': Icons.calendar_today_rounded, 'label': 'Agenda', 'gradient': AppColors.sunriseGradient},
      {'icon': Icons.description_outlined, 'label': 'Presupuestos', 'gradient': AppColors.popGradient},
      {'icon': Icons.group_add_outlined, 'label': 'Clientes', 'gradient': AppColors.oceanGradient},
      {'icon': Icons.payments_outlined, 'label': 'Finanzas', 'gradient': AppColors.morningGradient},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) => _buildToolTile(context, action, colorScheme)).toList(),
    );
  }

  Widget _buildToolTile(BuildContext context, Map<String, dynamic> action, ColorScheme colorScheme) {
    final width = (MediaQuery.of(context).size.width - 64) / 2;
    final budgetProvider = context.watch<BudgetProvider>();
    final showBadge = action['label'] == 'Presupuestos' && budgetProvider.pendingBudgetsCount > 0;
    
    final label = action['label'] as String;
    final gradient = action['gradient'] as List<Color>;

    return InkWell(
      onTap: () {
        if (label == 'Presupuestos') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetsListPage()));
        } else if (label == 'Clientes') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsListPage()));
        } else if (label == 'Agenda') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CitasListPage()));
        }
      },
      borderRadius: BorderRadius.circular(28),
      child: GlassCard(
        width: width,
        height: 130, 
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(28),
        opacity: 0.04,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gradient.first.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action['icon'] as IconData, color: gradient.first, size: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: colorScheme.onSurface, letterSpacing: -0.2),
                ),
                if (showBadge)
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.5), blurRadius: 4)],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessFAB(BuildContext context, ColorScheme colorScheme) {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withRed(240)],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
             showModalBottomSheet(
               context: context,
               backgroundColor: Colors.transparent,
               builder: (context) => _buildFABMenu(context, colorScheme),
             );
          },
          customBorder: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 40, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFABMenu(BuildContext context, ColorScheme colorScheme) {
    return GlassCard(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      padding: const EdgeInsets.all(32),
      opacity: 0.95,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 32),
          _buildMenuOption(context, Icons.event_available_rounded, 'Agendar Visita', colorScheme.secondary, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewCitaPage()));
          }),
          const SizedBox(height: 12),
          _buildMenuOption(context, Icons.person_add_rounded, 'Nuevo Cliente', colorScheme.primary, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewClientPage()));
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      trailing: Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.3)),
      onTap: onTap,
    );
  }
}

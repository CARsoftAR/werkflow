import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class FinanzasPage extends StatelessWidget {
  const FinanzasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetProvider = context.watch<BudgetProvider>();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'FINANZAS',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainRevenueCard(budgetProvider, colorScheme),
            const SizedBox(height: 24),
            _buildSectionHeader('DETALLE DE INGRESOS', colorScheme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSmallStatCard(
                    'COBRADO',
                    '\$${budgetProvider.realIncome.toStringAsFixed(0)}',
                    Icons.check_circle_rounded,
                    Colors.green,
                    colorScheme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSmallStatCard(
                    'PENDIENTE',
                    '\$${budgetProvider.projectedIncome.toStringAsFixed(0)}',
                    Icons.timer_rounded,
                    Colors.orange,
                    colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('MÉTRICAS DE NEGOCIO', colorScheme),
            const SizedBox(height: 16),
            _buildMetricTile(
              'Tasa de Conversión',
              '${budgetProvider.conversionRate.toStringAsFixed(1)}%',
              'Porcentaje de presupuestos aprobados',
              Icons.trending_up_rounded,
              Colors.blue,
              colorScheme,
            ),
            const SizedBox(height: 16),
            _buildMetricTile(
              'Ticket Promedio',
              '\$${_calculateAverageTicket(budgetProvider).toStringAsFixed(0)}',
              'Ingreso medio por presupuesto',
              Icons.receipt_long_rounded,
              Colors.purple,
              colorScheme,
            ),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  double _calculateAverageTicket(BudgetProvider provider) {
    if (provider.budgets.isEmpty) return 0;
    final total = provider.budgets.fold(0.0, (sum, b) => sum + b.totalGeneral);
    return total / provider.budgets.length;
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: colorScheme.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildMainRevenueCard(BudgetProvider provider, ColorScheme colorScheme) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(32),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROYECTADO TOTAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: colorScheme.primary.withOpacity(0.6),
                ),
              ),
              Icon(Icons.payments_rounded, color: colorScheme.primary.withOpacity(0.3), size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${provider.totalProjectedIncome.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Basado en presupuestos aprobados y pendientes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface.withOpacity(0.3),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtitle, IconData icon, Color color, ColorScheme colorScheme) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.05,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

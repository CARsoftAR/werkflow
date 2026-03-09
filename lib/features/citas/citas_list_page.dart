import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cita_provider.dart';
import '../../providers/client_provider.dart';
import '../../models/models.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';
import '../budgets/new_budget_page.dart';
import 'new_cita_page.dart';

class CitasListPage extends StatefulWidget {
  const CitasListPage({super.key});

  @override
  State<CitasListPage> createState() => _CitasListPageState();
}

class _CitasListPageState extends State<CitasListPage> {
  String _activeFilter = 'Pendiente';
  final List<String> _filters = ['Pendiente', 'Atendida', 'Cancelada', 'Todas'];

  @override
  Widget build(BuildContext context) {
    final citaProvider = context.watch<CitaProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final filteredCitas = _activeFilter == 'Todas'
        ? citaProvider.citas
        : citaProvider.citas.where((c) => c.estado == _activeFilter).toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'AGENDA DE CITAS',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.5),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: filteredCitas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredCitas.length,
                    itemBuilder: (context, index) {
                      final cita = filteredCitas[index];
                      return _buildCitaCard(context, cita);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewCitaPage())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_task_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('No hay citas en este estado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCitaCard(BuildContext context, Cita cita) {
    final clients = context.watch<ClientProvider>().clients;
    final client = clients.cast<Cliente?>().firstWhere((c) => c?.id == cita.clienteId, orElse: () => null);
    
    Color statusColor;
    switch (cita.estado) {
      case 'Pendiente': statusColor = Colors.orange; break;
      case 'Atendida': statusColor = Colors.green; break;
      case 'Cancelada': statusColor = Colors.grey; break;
      default: statusColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(cita.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(32)),
          child: const Icon(Icons.delete_forever, color: Colors.white),
        ),
        onDismissed: (_) => context.read<CitaProvider>().deleteCita(cita.id!),
child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewCitaPage(cita: cita))),
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${cita.fechaHora.day}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: statusColor, letterSpacing: -1)),
                        const SizedBox(height: 2),
                        Text(
                          '${_getMonthName(cita.fechaHora.month)}'.toUpperCase(), 
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client?.nombre ?? "Cliente #${cita.clienteId}", 
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withOpacity(0.3)),
                            const SizedBox(width: 6),
                            Text(
                              TimeOfDay.fromDateTime(cita.fechaHora).format(context), 
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            cita.estado.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (cita.estado == 'Pendiente')
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 24),
                        onPressed: () => context.read<CitaProvider>().markAsAttended(cita.id!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }
}

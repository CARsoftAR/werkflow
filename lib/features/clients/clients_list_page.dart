import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';
import '../../models/models.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';
import 'new_client_page.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientProvider = context.watch<ClientProvider>();
    final clients = clientProvider.searchClients(_searchQuery);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'CLIENTES',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewClientPage())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: clients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 120),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return _buildClientCard(context, client);
                    },
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          textAlign: TextAlign.start,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Búsqueda Universal Flowy...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_alt_rounded, size: 80, color: AppColors.primary.withOpacity(0.2)),
          ),
          const SizedBox(height: 32),
          const Text(
            'Sin clientes registrados',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Agregá tu primer cliente para empezar.',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 48),
          _buildFlowyButton(
            'AGREGAR CLIENTE',
            Icons.person_add_rounded,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewClientPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowyButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: AppColors.sunriseGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildClientCard(BuildContext context, Cliente client) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(client.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        onDismissed: (_) => context.read<ClientProvider>().deleteClient(client.id!),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => NewClientPage(client: client))
            ),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      client.nombre[0].toUpperCase(), 
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.nombre, 
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.5)
                        ),
                        if (client.celular != null)
                          Text(
                            client.celular!, 
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.bold)
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withOpacity(0.2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


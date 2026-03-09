import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_page.dart';

import 'package:provider/provider.dart';
import 'providers/client_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/cita_provider.dart';

class WerkFlowApp extends StatelessWidget {
  const WerkFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientProvider()..loadClients()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..loadBudgets()),
        ChangeNotifierProvider(create: (_) => CitaProvider()..loadCitas()),
      ],
      child: MaterialApp(
        title: 'WerkFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: const DashboardPage(),
      ),
    );
  }
}

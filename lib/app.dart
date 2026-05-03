import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/citas/alarm_ringing_page.dart';
import 'package:alarm/alarm.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'providers/client_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/cita_provider.dart';
import 'providers/business_provider.dart';

import 'features/main/main_screen.dart';
import 'features/splash/splash_screen.dart';

class WerkFlowApp extends StatefulWidget {
  const WerkFlowApp({super.key});

  @override
  State<WerkFlowApp> createState() => _WerkFlowAppState();
}

class _WerkFlowAppState extends State<WerkFlowApp> {
  late StreamSubscription<AlarmSettings>? subscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    subscription = Alarm.ringStream.stream.listen(
      (settings) => _navigateToRingingPage(settings),
    );
  }

  void _navigateToRingingPage(AlarmSettings settings) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => AlarmRingingPage(settings: settings),
      ),
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientProvider()..loadClients()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..loadBudgets()),
        ChangeNotifierProvider(create: (_) => CitaProvider()..loadCitas()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()..loadBusinessInfo()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Ñomin Agenda',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}



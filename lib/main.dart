import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup logic (DI, DB, etc.)
  await setupLocator();
  
  runApp(const WerkFlowApp());
}

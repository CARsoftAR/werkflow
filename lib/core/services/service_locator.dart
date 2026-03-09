import 'package:get_it/get_it.dart';
import '../database/database_service.dart';
import 'notification_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Database Service
  final dbService = DatabaseService();
  locator.registerSingleton<DatabaseService>(dbService);

  // Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  locator.registerSingleton<NotificationService>(notificationService);

  // Initialize database
  await dbService.database;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'data/datasources/local/database_service.dart';
import 'data/services/notification_service.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup dependencies
  await setupDependencies();

  // Initialize services
  await getIt<DatabaseService>().init();
  await getIt<NotificationService>().init();

  runApp(const FinancialPlannerApp());
}

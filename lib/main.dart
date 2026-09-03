import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'app/hrms_app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final service = HrmsService();
  try { await NotificationService(service.backend).initialize(); } catch (_) {}
  runApp(HrmsApp(service: service));
}

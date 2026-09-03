import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'hrms_backend_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is initialized by the application entry point before messages are handled.
}

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final HrmsBackendService backend;
  NotificationService(this.backend);

  Future<String?> initialize() async {
    if (kIsWeb) return null;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final token = await messaging.getToken();
    final user = backend.user;
    if (token != null && user != null) {
      await backend.db.collection('users').doc(user.uid).set({'fcmToken': token, 'updatedAt': DateTime.now().toUtc().toIso8601String()}, SetOptions(merge: true));
    }
    messaging.onTokenRefresh.listen((newToken) async {
      final current = backend.user;
      if (current != null) await backend.db.collection('users').doc(current.uid).set({'fcmToken': newToken}, SetOptions(merge: true));
    });
    return token;
  }
}

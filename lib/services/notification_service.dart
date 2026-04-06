import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    await Permission.notification.request();
  }

  static Future<void> showInactivityAlert() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'routine_intelligence_channel',
      'Routine Intelligence Alerts',
      channelDescription: 'Alerts for when specific routine anomalies occur.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Inactivity Detected',
      'No movement detected for 4 hours. Tap to dismiss or call for help.',
      platformDetails,
    );
  }
}

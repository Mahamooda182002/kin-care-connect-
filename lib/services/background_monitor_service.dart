import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackgroundMonitorService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'kin_care_channel',
        initialNotificationTitle: 'Kin Care Connect',
        initialNotificationContent: 'Monitoring activity...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
    }

    DateTime lastMovement = DateTime.now();
    double lastX = 0, lastY = 0, lastZ = 0;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'default_user';

    accelerometerEventStream().listen((event) {
      double delta = (event.x - lastX).abs() +
          (event.y - lastY).abs() +
          (event.z - lastZ).abs();
      if (delta > 1.5) {
        lastMovement = DateTime.now();
        lastX = event.x;
        lastY = event.y;
        lastZ = event.z;
        FirebaseFirestore.instance
            .collection('status')
            .doc(uid)
            .set({'last_seen': FieldValue.serverTimestamp()});
      }
    });

    Timer.periodic(const Duration(minutes: 30), (timer) {
      final diff = DateTime.now().difference(lastMovement);
      if (diff.inHours >= 4) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Kin Care Connect',
            content: 'No movement detected for 4 hours!',
          );
        }
      }
    });
  }
}

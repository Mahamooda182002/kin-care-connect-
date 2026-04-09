import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BackgroundMonitorService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'routine_intelligence_bg',
      'Routine Monitor',
      description: 'Continuously monitors movement to ensure elder safety.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'routine_intelligence_bg',
        initialNotificationTitle: 'Routine Monitor Active',
        initialNotificationContent: 'Monitoring movement...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("BG Firebase init error: $e");
    }

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    const double movementThreshold = 1.5;
    
    // Listen to accelerometer events in background
    accelerometerEventStream().listen((AccelerometerEvent event) async {
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      bool currentlyMoving = (magnitude - 9.8).abs() > movementThreshold;

      if (currentlyMoving) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "Routine Monitor",
            content: "Movement Detetced at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          );
        }
        
        try {
          // Write to Firestore status collection using a dummy uid like 
          const userId = 'user_dummy_123';
          await FirebaseFirestore.instance.collection('status').doc(userId).set({
            'last_seen': FieldValue.serverTimestamp(),
            'isMoving': true,
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Failed Firestore BG sync: $e");
        }
      }
    });
  }
}

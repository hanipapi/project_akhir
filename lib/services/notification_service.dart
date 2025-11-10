// Lokasi File: lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // 1. Fungsi Inisialisasi (Tetap sama)
  static Future<void> init() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    
    // Minta izin notifikasi saat inisialisasi (untuk Android 13+)
     await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // 2.  Notifikasi instan
  static Future<void> showSimpleNotification(String title, String body) async {
    // Detail notifikasi untuk Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id_simple', // ID Channel baru
      'General Notifications',
      channelDescription: 'Notifikasi umum dan feedback aplikasi',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Detail notifikasi untuk iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Tampilkan notifikasi
    await _plugin.show(
      DateTime.now().millisecond, // ID unik berdasarkan waktu
      title, // Judul dari parameter
      body,  // Body dari parameter
      details,
    );
  }
}
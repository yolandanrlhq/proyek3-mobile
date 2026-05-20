import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel haraChannel =
      AndroidNotificationChannel(
    'hara_notifications_final',
    'Hara Notifications',
    description: 'Notifikasi Hara Hijabneeds',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('hara_hijabneeds'),
  );

  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await localNotifications.initialize(settings);

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(haraChannel);

    final token = await messaging.getToken();
    print('FCM TOKEN BARU: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.data['title'] ?? 'Hara Hijabneeds',
        message.data['body'] ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hara_notifications_final',
            'Hara Notifications',
            channelDescription: 'Notifikasi Hara Hijabneeds',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('hara_hijabneeds'),
          ),
        ),
      );
    });
  }

  static Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM TOKEN BARU: $token');
    return token;
  }
}
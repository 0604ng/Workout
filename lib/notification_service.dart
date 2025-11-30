import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: iOS,
    );

    await _notification.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          // Navigate to specific screen based on payload
        }
      },
    );

    // Request permissions for iOS
    // Request permissions for Android 13+
    _notification
        .resolvePlatformSpecificImplementation;
    AndroidFlutterLocalNotificationsPlugin>()
        .requestNotificationsPermission();
  }

  static Future<void> scheduleNotification({
    required int id,
    required DateTime date,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notification.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel',
          'Workout Schedule',
          channelDescription: 'Notifications for workout schedules',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notification.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Instant Notifications',
          channelDescription: 'Instant workout notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notification.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notification.pendingNotificationRequests();
  }
}

extension on () {
  requestNotificationsPermission() {}
}

extension on Type {
  void operator >(other) {}
}
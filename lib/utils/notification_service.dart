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
    const settings = InitializationSettings(android: android);

    await _notification.initialize(settings);
  }

  static Future<void> scheduleNotification({
    required int id,
    required DateTime date,
    required String title,
    required String body,
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
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notification.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }
}
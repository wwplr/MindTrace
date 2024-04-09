import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FlutterNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  Future<void> initialiseNotifications() async {
    const initSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification(
      {int id = 0,
        String? title,
        String? body,
        String? payLoad,
        required DateTime scheduledNotificationDateTime}) async {

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    return flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.local,
        ),
        await NotificationDetails(iOS: DarwinNotificationDetails()),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
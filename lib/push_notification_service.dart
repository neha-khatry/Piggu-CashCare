import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Initialize timezone package
    initializeTimeZones();
  }

  // Request Permission to Schedule Exact Alarms (Android 12+)
  static Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid && androidVersion >= 12) {
      // Launch the exact alarm permission screen
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }

  // Static getter for Android version
  static int get androidVersion {
    return int.parse(Platform.operatingSystemVersion.split(' ')[1].split('.')[0]);
  }

  // Schedule Notification Method
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Ensure that the scheduled time is in the future
      if (scheduledTime.isBefore(DateTime.now())) {
        print('Cannot schedule notification in the past');
        throw Exception('Scheduled time cannot be in the past');
      }

      // Request permission for exact alarm if needed
      await requestExactAlarmPermission();

      // Convert DateTime to TZDateTime
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Log the scheduled time for debugging
      print("Scheduling notification at: $tzScheduledTime");

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'goal_channel', // Define a channel ID
        'Goal Reminders', // Channel name
        channelDescription: 'Channel for goal reminders',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // Schedule the notification with a specific time in the local timezone
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID (0 to allow automatic ID generation)
        title, // Notification Title
        body,  // Notification Body
        tzScheduledTime, // Scheduled time
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      );

      print("Notification scheduled successfully at $tzScheduledTime");

    } catch (e) {
      print('Failed to schedule notification: $e');
      throw Exception('Notification scheduling failed: $e');
    }
  }
}

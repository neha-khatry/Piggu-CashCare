import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initNotifications() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the notifications plugin without onSelectNotification
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permission from the user for iOS
    await _firebaseMessaging.requestPermission();

    // Fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

    // Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message in foreground: ${message.notification?.title}');
      _showNotification(message.notification?.title ?? 'New Notification',
          message.notification?.body ?? 'You have a new notification');
    });

    // Handle the case when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! Navigate to appropriate screen');
    });

    // Handle when the app is opened from a terminated state with a message
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
      }
    });
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Add background message processing logic here (e.g., updating local data)
  }

  // Show local notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'income_channel', // Channel ID
      'Income Notifications', // Channel name
      channelDescription: 'Notifications related to income activities',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }

  // Handle notification tap (on select notification)
  Future<void> onSelectNotification(String? payload) async {
    // Navigate to a specific screen or perform an action based on the notification payload
    print('Notification tapped! Payload: $payload');
  }
}

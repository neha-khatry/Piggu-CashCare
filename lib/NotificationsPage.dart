import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _filteredNotifications = [];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // If user is not logged in, redirect to login page
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          backgroundColor: Colors.pink,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to Login Page
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Please Log in'),
          ),
        ),
      );
    }

    // Streams for notifications
    final goalStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots()
        .map((goalSnapshot) =>
        goalSnapshot.docs.map((doc) => 'New goal added: ${doc['goal']}').toList());

    final incomeStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('income')
        .snapshots()
        .map((incomeSnapshot) => incomeSnapshot.docs
        .map((doc) => 'New income received: ${doc['source']} - NPR ${doc['amount']}')
        .toList());

    final expenseStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .map((expenseSnapshot) => expenseSnapshot.docs
        .map((doc) => 'New expense: ${doc['source']} - NPR ${doc['amount']}')
        .toList());

    // Combine all streams using RxDart
    final combinedStream = Rx.combineLatest3<List<String>, List<String>, List<String>, List<String>>(
      goalStream, incomeStream, expenseStream,
          (goals, income, expenses) {
        return [...goals, ...income, ...expenses];
      },
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Go back to the previous screen
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          backgroundColor: Colors.pink,
          actions: [
            // Search icon
            IconButton(
              icon: Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
          ],
        ),
        body: StreamBuilder<List<String>>(
          stream: combinedStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Notifications data
            final notifications = snapshot.data ?? [];

            // Filter notifications based on search query
            _filteredNotifications = notifications
                .where((notification) => notification.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            // If no notifications, show a placeholder message
            if (_filteredNotifications.isEmpty) {
              return Center(
                child: Text(
                  'No notifications available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: ListView.builder(
                itemCount: _filteredNotifications.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          _filteredNotifications[index],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Timestamp: ${DateTime.now().toLocal()}'),
                        leading: Icon(Icons.notifications, color: Colors.pink),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteNotification(index, userId);
                          },
                        ),
                        onTap: () {
                          // Implement functionality to mark notifications as read (e.g., changing the color)
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Show search dialog to filter notifications
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Notifications'),
          content: TextField(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            decoration: InputDecoration(
              labelText: 'Enter search term...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Delete a specific notification from Firestore
  Future<void> _deleteNotification(int index, String? userId) async {
    if (userId == null) return;

    // Get the notification text (you could use a more structured approach)
    final notification = _filteredNotifications[index];

    // Fetch the correct collection based on the notification type
    final collectionRef = _getNotificationCollection(notification);
    if (collectionRef != null) {
      // Query for the notification document and delete it
      final querySnapshot = await collectionRef.where('message', isEqualTo: notification).get();
      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await collectionRef.doc(docId).delete(); // Delete the notification from Firestore
      }
    }

    setState(() {
      _filteredNotifications.removeAt(index); // Remove it from the UI
    });
  }

  // Get the corresponding collection for each notification type
  CollectionReference? _getNotificationCollection(String notification) {
    if (notification.contains('goal')) {
      return _firestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('goals');
    } else if (notification.contains('income')) {
      return _firestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('income');
    } else if (notification.contains('expense')) {
      return _firestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('expenses');
    }
    return null;
  }

  // Refresh notifications (pull-to-refresh)
  Future<void> _refreshNotifications() async {
    setState(() {});
  }
}

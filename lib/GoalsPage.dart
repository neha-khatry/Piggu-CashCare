import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalSettingPage extends StatefulWidget {
  final User user;

  GoalSettingPage({required this.user});

  @override
  _GoalSettingPageState createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  final _goalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _goals = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadGoals();
    _listenForGoalChanges();
  }

  // Initialize local notifications
  void _initializeNotifications() {
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show notification
  Future<void> _showNotification({required String title, required String message}) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'goals_channel',
      'Goals Notifications',
      channelDescription: 'Notifications for goal updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      message,
      notificationDetails,
    );
  }

  // Load goals from Firestore
  Future<void> _loadGoals() async {
    try {
      final goalsSnapshot = await _firestore
          .collection('users')
          .doc(widget.user.uid)
          .collection('goals')
          .get();

      setState(() {
        _goals = goalsSnapshot.docs.map((doc) => doc['goal'] as String).toList();
      });
    } catch (e) {
      print("Error loading goals: $e");
    }
  }

  // Save goal to Firestore
  Future<void> _saveGoalToFirestore(String goal) async {
    try {
      await _firestore
          .collection('users')
          .doc(widget.user.uid)
          .collection('goals')
          .add({'goal': goal, 'status': 'in-progress', 'createdAt': Timestamp.now()});
    } catch (e) {
      print("Error saving goal: $e");
    }
  }

  // Delete goal from Firestore
  Future<void> _deleteGoalFromFirestore(String goal) async {
    try {
      final goalsSnapshot = await _firestore
          .collection('users')
          .doc(widget.user.uid)
          .collection('goals')
          .where('goal', isEqualTo: goal)
          .get();

      for (var doc in goalsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Error deleting goal: $e");
    }
  }

  // Listen for changes in Firestore
  void _listenForGoalChanges() {
    _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('goals')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _showNotification(
            title: 'New Goal Added!',
            message: 'You added: ${change.doc['goal']}',
          );
        } else if (change.type == DocumentChangeType.modified) {
          if (change.doc['status'] == 'reached') {
            _showNotification(
              title: 'Goal Reached!',
              message: 'Congratulations! You reached your goal: ${change.doc['goal']}',
            );
          }
        }
      }
    });
  }

  String? _validateGoal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a goal';
    }
    return null;
  }

  void _submitGoal() {
    if (_formKey.currentState!.validate()) {
      String goal = _goalController.text.trim();
      setState(() {
        _goals.add(goal);
      });

      _saveGoalToFirestore(goal);
      _goalController.clear();
    }
  }

  void _deleteGoal(int index) {
    String goalToDelete = _goals[index];
    setState(() {
      _goals.removeAt(index);
    });

    _deleteGoalFromFirestore(goalToDelete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(
          'Set Goals',
          style: TextStyle(fontFamily: 'Pacifico', color: Colors.white),
        ),
        backgroundColor: Colors.pink,
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _goalController,
                        decoration: InputDecoration(
                          labelText: 'Enter your goal',
                          hintText: 'e.g., Save \$500 this month',
                          prefixIcon: Icon(Icons.flag, color: Colors.pink),
                          labelStyle: TextStyle(color: Colors.pink),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink.shade700),
                          ),
                        ),
                        validator: _validateGoal,
                        style: TextStyle(color: Colors.pink.shade800),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: _submitGoal,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade700,
                          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.pink.shade900,
                          elevation: 5.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Goals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade700,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Expanded(
                        child: _goals.isEmpty
                            ? Center(
                          child: Text(
                            'No goals yet. Start by adding one!',
                            style: TextStyle(
                              color: Colors.pink.shade400,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        )
                            : ListView.builder(
                          itemCount: _goals.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.check_circle, color: Colors.green),
                                title: Text(
                                  _goals[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink.shade800,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteGoal(index);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

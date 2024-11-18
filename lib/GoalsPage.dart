import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'push_notification_service.dart';
import 'dart:io' show Platform;

class GoalSettingPage extends StatefulWidget {
  final User user;

  GoalSettingPage({required this.user});

  @override
  _GoalSettingPageState createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  final _goalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDeadlineDateTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _storeFCMToken();
    PushNotificationService.initialize();
  }

  Future<void> _storeFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(widget.user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  // Request Permission to Schedule Exact Alarms (Android 12+)
  Future<void> requestExactAlarmPermission(BuildContext context) async {
    if (Platform.isAndroid && androidVersion >= 12) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }

  int get androidVersion {
    // Get Android version number
    return int.parse(Platform.operatingSystemVersion.split(' ')[1].split('.')[0]);
  }

  // Select Deadline Date and Time
  Future<void> _selectDeadlineDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Show time picker after selecting a date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          // Combine selected date and time
          _selectedDeadlineDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitGoal() async {
    if (_formKey.currentState!.validate()) {
      String goalText = _goalController.text;

      if (_selectedDeadlineDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a deadline date and time')),
        );
        return;
      }

      // Calculate reminder time 3 days before the deadline date and time at 9:00 AM
      DateTime reminderDate = _selectedDeadlineDateTime!.subtract(Duration(days: 3));
      DateTime reminderTime = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9, 0);

      // Log values to help debug
      print('Selected deadline: $_selectedDeadlineDateTime');
      print('Calculated reminder time: $reminderTime');

      // Check if reminderTime is valid (not in the past)
      if (reminderTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder time cannot be in the past')),
        );
        return;
      }

      try {
        // Request permission to schedule exact alarms (for Android 12+)
        await requestExactAlarmPermission(context);

        // Store goal in Firestore
        await _firestore.collection('users').doc(widget.user.uid).collection('goals').add({
          'goal': goalText,
          'deadlineDateTime': Timestamp.fromDate(_selectedDeadlineDateTime!),
          'reminderTime': Timestamp.fromDate(reminderTime),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Schedule notification 3 days before the deadline
        await PushNotificationService.scheduleNotification(
          title: 'Goal Reminder',
          body: 'Your goal "$goalText" is approaching its deadline!',
          scheduledTime: reminderTime,
        );

        _goalController.clear();
        setState(() {
          _selectedDeadlineDateTime = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Goal added and reminder set successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add goal: $e')),
        );
        print('Error: $e'); // Log the error for debugging
      }
    }
  }

  String? _validateGoal(String? value) {
    return (value == null || value.isEmpty) ? 'Please enter a goal' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _goalController,
                decoration: InputDecoration(labelText: 'Enter your goal'),
                validator: _validateGoal,
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () => _selectDeadlineDateTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Deadline Date and Time',
                    errorText: _selectedDeadlineDateTime == null
                        ? 'Please select a deadline date and time'
                        : null,
                  ),
                  child: Text(
                    _selectedDeadlineDateTime == null
                        ? 'Select date and time'
                        : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDeadlineDateTime!),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitGoal,
                child: Text('Submit Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

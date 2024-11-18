import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:piggu/firebase_api.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart';
import 'LoginPage.dart';
import 'welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeTimeZones();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piggu:CashCare', // Update this line
      theme: ThemeData(
        primarySwatch: Colors.green, // Update this line
      ),
      home: WelcomePage(),
    );
  }
}
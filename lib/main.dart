import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:piggu/services/firebase_api.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart';
import 'welcome_page.dart';
import 'SignupPage.dart';
import 'ResetPasswordPage.dart';
import 'LoginPage.dart';// Add this import

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
      debugShowCheckedModeBanner: false,
      title: 'Piggu:CashCare', // Update this line
      theme: ThemeData(
        primarySwatch: Colors.green, // Update this line
      ),
      // Define named routes
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/reset-password': (context) => ResetPasswordPage(),
      },
    );
  }
}



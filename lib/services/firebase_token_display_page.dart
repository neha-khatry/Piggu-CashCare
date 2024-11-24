// lib/firebase_token_display_page.dart
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class FirebaseTokenDisplayPage extends StatefulWidget {
  @override
  _FirebaseTokenDisplayPageState createState() =>
      _FirebaseTokenDisplayPageState();
}

class _FirebaseTokenDisplayPageState extends State<FirebaseTokenDisplayPage> {
  String? _firebaseIdToken; // This can be nullable, since we handle null.

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    FirebaseService firebaseService = FirebaseService();
    String? token = await firebaseService.getFirebaseIdToken();
    setState(() {
      _firebaseIdToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase ID Token Display'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: _firebaseIdToken == null
            ? CircularProgressIndicator() // Show loading indicator while token is being fetched
            : Text(
          'Firebase ID Token: ${_firebaseIdToken ?? "No token available"}', // Handle null case here
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

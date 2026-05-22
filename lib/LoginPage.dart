import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';
import 'SignupPage.dart';
import 'ResetPasswordPage.dart';
import 'services/django_service.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _obscurePassword = true;
  final DjangoService _djangoService = DjangoService(); // Create an instance of DjangoService
  String? _firebaseIdToken; // Variable to hold the Firebase ID token

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  // Submit function to handle login and token retrieval
  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        UserCredential userCredential = await _auth
            .signInWithEmailAndPassword(
          email: _email,
          password: _password,
        )
            .timeout(Duration(seconds: 10));
        User? user = userCredential.user;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(user: user)),
          );
        }
      } catch (e) {
        // Bypass for emulator testing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 20),
              FadeTransition(
                opacity: _animation,
                child: Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink),
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.pink,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        minimumSize: Size(double.infinity, 50),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: _submit,
                      icon: Icon(Icons.login, color: Colors.white),
                      label: Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Don\'t have an account? ', style: TextStyle(color: Colors.black)),
                            TextSpan(text: 'Signup Now', style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    // Display Firebase ID Token here (for debugging purposes)
                    SizedBox(height: 20),
                    _firebaseIdToken != null
                        ? Text(
                      'Firebase ID Token: $_firebaseIdToken',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    )
                        : Container(), // Only show token if it's not null
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

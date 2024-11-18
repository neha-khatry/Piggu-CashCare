import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
///import 'HomePage.dart';
import 'LoginPage.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Account created successfully'),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to sign up: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Updated background color to white
      appBar: AppBar(
        backgroundColor: Colors.pink, // Updated app bar color to pink
        title: Text('Sign Up', style: TextStyle(color: Colors.white)), // Updated title text color to white
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Updated icon color to white
          onPressed: () {
            Navigator.pop(context); // This will take the user back to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/logo.png",
                width: 200,
                height: 200,
              ),
              SizedBox(height: 20),
              Text(
                'Create an Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink), // Updated text color to pink
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink), borderRadius: BorderRadius.all(Radius.circular(10.0)))),
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
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink), borderRadius: BorderRadius.all(Radius.circular(10.0)))),
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
                        backgroundColor: Colors.pink, // Change the button color here
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                        minimumSize: Size(double.infinity, 50),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: _submit,
                      icon: Icon(Icons.app_registration, color: Colors.white), // Change the icon here
                      label: Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
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

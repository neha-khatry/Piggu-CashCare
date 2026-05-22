import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/django_service.dart';
import 'LoginPage.dart';
import 'TermsOfServicePage.dart';
import 'PrivacyPolicyPage.dart';
import 'package:flutter/gestures.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isTermsAgreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isConfirmPasswordVisible = false;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final DjangoService _djangoService = DjangoService();

  bool _isLoading = false;
  String? _passwordError;
  String? _termsError;

  void _validatePasswords() {
    setState(() {
      if (_password != _confirmPassword) {
        _passwordError = 'Passwords do not match';
      } else {
        _passwordError = null;
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_isTermsAgreed) {
        setState(() {
          _termsError =
          'You must agree to the Terms of Service and Privacy Policy.';
        });
        return;
      }

      if (_passwordError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_passwordError!),
        ));
        return;
      }

      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
        _termsError = null; // Reset terms error if already agreed
      });
      try {
        User? user = await _firebaseAuthService.signUpWithEmail(
            _email, _password);
        if (user != null) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'A verification email has been sent to $_email. Please verify your email.'),
          ));
          _startEmailVerificationCheck(user);
          await _djangoService.saveUserToDjango(user.uid, _email);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to sign up: $e'),
        ));
      }
    }
  }

  void _startEmailVerificationCheck(User user) {
    Future.delayed(Duration(seconds: 5), () async {
      await user.reload();
      User? updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser?.emailVerified ?? false) {
        await _djangoService.saveUserToDjango(user.uid, _email);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Email verified! Account created successfully.'),
        ));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Sign Up',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink),
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
                        hintText: 'Enter your Gmail address',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.email, color: Colors.pink),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.endsWith('@gmail.com')) {
                          return 'Only Gmail accounts are allowed';
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
                        hintText: 'Enter a secure password',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock, color: Colors.pink),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.pink,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _password = value;
                        setState(() {
                          _isConfirmPasswordVisible = value.isNotEmpty;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    if (_isConfirmPasswordVisible)
                      TextFormField(
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.lock, color: Colors.pink),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.pink,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink),
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _confirmPassword = value;
                          _validatePasswords();
                        },
                      ),
                    if (_passwordError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _passwordError!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _isTermsAgreed,
                          onChanged: (value) {
                            setState(() {
                              _isTermsAgreed = value!;
                              _termsError = null;
                            });
                          },
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(color: Colors.pink, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Terms of Service",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TermsOfServicePage(),
                                        ),
                                      );
                                    },
                                ),
                                TextSpan(text: " and "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PrivacyPolicyPage(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_termsError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _termsError!,
                          style: TextStyle(color: Colors.red),
                        ),
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
                      icon: Icon(Icons.app_registration, color: Colors.white),
                      label: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
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
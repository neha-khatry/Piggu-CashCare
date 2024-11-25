import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'AccountPage.dart'; // Import AccountPage for navigation

class CreateProfilePage extends StatefulWidget {
  final bool isEditing;  // To check if we are editing an existing profile
  final String? name;    // Data passed from AccountPage
  final String? address; // Data passed from AccountPage
  final String? email;   // Data passed from AccountPage
  final String? phone;   // Data passed from AccountPage

  CreateProfilePage({
    this.isEditing = false,  // Constructor to handle the edit mode
    this.name,
    this.address,
    this.email,
    this.phone,
  });

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _email = '';
  String _phone = '';
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _name = widget.name ?? '';    // Load passed data
      _address = widget.address ?? '';
      _email = widget.email ?? '';
      _phone = widget.phone ?? '';
    }
  }

  // Function to upload profile image to Firebase Storage (optional)
  Future<String?> _uploadProfileImage(File imageFile) async {
    // You can use Firebase Storage here to upload the image and get the URL
    // For now, returning a placeholder image URL
    return "https://www.example.com/image.jpg";
  }

  // Function to save profile data into Firestore
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      String? imageUrl;

      // Upload profile image if available
      if (_profileImage != null) {
        imageUrl = await _uploadProfileImage(_profileImage!);
      }

      // Save profile data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'name': _name,
        'address': _address,
        'email': _email,
        'phone': _phone,
        'profile_image': imageUrl, // Save the image URL (if any)
      });

      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Redirect to AccountPage after a short delay
      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountPage(user: FirebaseAuth.instance.currentUser!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Profile' : 'Create Profile'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Display Person Icon Instead of Image Picker
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.pink,
                child: Icon(
                  Icons.person, // Use person icon as default
                  size: 50,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: _phone,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) => _phone = value!,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveProfile,
                child: Text(widget.isEditing ? 'Save Changes' : 'Save Profile'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

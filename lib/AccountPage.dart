import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'HistoryPage.dart';
import 'create_profile_page.dart';

class AccountPage extends StatelessWidget {
  final User? user;

  AccountPage({this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text("No user logged in"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Show the Create Profile option if profile is missing
            return _buildCreateProfilePrompt(context);
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return _buildProfileView(context, userData);
        },
      ),
    );
  }

  // Widget to prompt user to create a profile
  Widget _buildCreateProfilePrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Profile not created yet!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to CreateProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProfilePage(
                    isEditing: false, // Indicate that it's a new profile
                  ),
                ),
              );
            },
            icon: Icon(Icons.add),
            label: Text('Create Profile'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              // Perform logout action
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.exit_to_app),
            label: Text('Logout'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // Profile view with options
  Widget _buildProfileView(BuildContext context, Map<String, dynamic> data) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.pink,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Welcome, ${data['name'] ?? 'User'}!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildDetailsSection(context, data),
          _buildOptionsSection(context),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildDetailRow('Name:', data['name'] ?? 'No Name Provided'),
            _buildDetailRow('Address:', data['address'] ?? 'No Address Provided'),
            _buildDetailRow('Email:', data['email'] ?? 'No Email Provided'),
            _buildDetailRow('Phone:', data['phone'] ?? 'No Phone Provided'),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to CreateProfilePage for editing
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProfilePage(
                      isEditing: true,
                      name: data['name'],
                      address: data['address'],
                      email: data['email'],
                      phone: data['phone'],
                    ),
                  ),
                );
              },
              icon: Icon(Icons.edit),
              label: Text('Edit Details'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('FAQs'),
            onTap: () {
              // Navigate to FAQs page
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            children: [
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Change Password'),
                onTap: () {
                  _sendPasswordResetEmail(context);
                },
              ),
            ],
          ),
          // Logout option moved to the bottom
          ListTile(
            leading: Icon(Icons.exit_to_app), // Ensure the correct icon
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No user logged in"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: FirebaseAuth.instance.currentUser!.email!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
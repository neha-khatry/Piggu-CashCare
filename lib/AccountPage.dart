import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart'; // Import your LoginPage
import 'HistoryPage.dart'; // Import your HistoryPage
import 'create_profile_page.dart'; // Import CreateProfilePage

class AccountPage extends StatelessWidget {
  final User? user;

  AccountPage({this.user});

  @override
  Widget build(BuildContext context) {
    // Check if user is null
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
            .doc(user!.uid) // Use currentUser safely here
            .snapshots(), // Listen for real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return _buildProfileView(context, userData);
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, Map<String, dynamic> data) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
        children: <Widget>[
          // Profile Image Section (Display Person Icon)
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

          // Profile Details Section
          _buildDetailsSection(context, data),

          // Options Section (History, FAQs, Settings, Logout)
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
                // Pass the existing user data to CreateProfilePage for editing
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProfilePage(
                      isEditing: true, // Set isEditing flag to true
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

  // Options Section (History, FAQs, Settings, Logout)
  Widget _buildOptionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              // Navigate to History page
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
              // Navigate to FAQs page (implement this page separately)
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
                  // Send password reset email
                  _sendPasswordResetEmail(context);
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
              );
            },
          ),
        ],
      ),
    );
  }

  // Function to send password reset email
  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      // Check if the user is logged in
      if (FirebaseAuth.instance.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No user logged in"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_profile_page.dart';
import 'LoginPage.dart';
import 'HistoryPage.dart';

class AccountPage extends StatelessWidget {
  final User user;
  AccountPage({required this.user});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateProfilePage()),
                        );
                      },
                      child: Text('Create Profile'),
                    ),
                    _buildMenuOptions(context),
                  ],
                ),
              );
            } else {
              Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    _buildMenuOptions(context),
                  ],
                ),
              );
            }
          },
        ),
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
            _buildDetailRow('Email:', data['email'] ?? 'No Email Provided'),
            _buildDetailRow('Phone:', data['phone'] ?? 'No Phone Number Provided'),
            _buildDetailRow('Address:', data['address'] ?? 'No Address Provided'),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProfilePage(),
                  ),
                );
              },
              icon: Icon(Icons.edit),
              label: Text('Edit Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.history),
          title: Text('History'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.account_balance_wallet),
          title: Text('Balance'),
          onTap: () {
            // TODO: Implement balance functionality
          },
        ),
        ListTile(
          leading: Icon(Icons.monetization_on),
          title: Text('Total Income'),
          onTap: () {
            // TODO: Implement total income functionality
          },
        ),
        ListTile(
          leading: Icon(Icons.category),
          title: Text('Expense Categories'),
          onTap: () {
            // TODO: Implement expense categories functionality
          },
        ),
        ListTile(
          leading: Icon(Icons.help),
          title: Text('FAQs'),
          onTap: () {
            // TODO: Implement FAQs functionality
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Log Out'),
          onTap: () {
            _signOut(context);
          },
        ),
      ],
    );
  }
}

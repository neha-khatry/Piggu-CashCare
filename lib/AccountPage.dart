import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_profile_page.dart';
import 'LoginPage.dart';
import 'HistoryPage.dart'; // Import the HistoryPage

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
      body: StreamBuilder<DocumentSnapshot>(
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
                    'Name: ${data['name']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Address: ${data['address']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text('History'),
                    onTap: () {
                      // Redirect to HistoryPage
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
              ),
            );
          }
        },
      ),
    );
  }
}

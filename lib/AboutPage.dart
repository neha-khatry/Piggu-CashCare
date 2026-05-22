import 'package:flutter/material.dart';
import 'PrivacyPolicyPage.dart';
import 'TermsOfServicePage.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: TextStyle(fontFamily: 'Roboto')),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 100,
                    color: Colors.pink,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Piggu:Cashcare',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.pink,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Piggu:Cashcare is your personal finance tracker, helping you to manage your income, expenses, set goals, and make predictions about your financial future. With features like receipt scanning, SMS parsing, and personalized recommendations, managing your finances has never been easier.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 10),
                  Text(
                    'Contact Us:',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'For feedback, suggestions, or inquiries, please email us at: support@piggu.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Divider(),
                  SizedBox(height: 10),
                  _buildNavigationTile(
                    context,
                    'Privacy Policy',
                        () {
                      // Navigate to Privacy Policy Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                      );
                    },
                  ),
                  _buildNavigationTile(
                    context,
                    'Terms of Service',
                        () {
                      // Navigate to Terms of Service Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TermsOfServicePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile(BuildContext context, String title, Function onTap) {
    return ListTile(
      leading: Icon(Icons.arrow_forward_ios),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => onTap(),
    );
  }
}

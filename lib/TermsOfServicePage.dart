import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service', style: TextStyle(fontFamily: 'Roboto')),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Terms of Service',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '''Effective Date: [Insert Date]

By using the Piggu:Cashcare mobile application and services, you agree to comply with and be bound by the following terms and conditions ("Terms"). Please read these Terms carefully before using our Services.

**1. Acceptance of Terms:**
By accessing or using our Services, you agree to be bound by these Terms and any additional terms or policies referenced herein.

**2. Account Creation:**
To access certain features of the app, you must create an account. You agree to provide accurate and complete information when creating your account, and you are responsible for maintaining the confidentiality of your account information.

**3. Use of Services:**
You may use the Services only for lawful purposes and in accordance with these Terms. You are prohibited from using the Services to:
- Violate any applicable laws or regulations.
- Engage in fraudulent activities or misuse the Services.
- Upload or transmit harmful, unlawful, or abusive content.

**4. Termination of Account:**
We reserve the right to suspend or terminate your account if you violate these Terms or for any other reason at our sole discretion.

**5. Limitation of Liability:**
We are not liable for any damages or losses arising from your use or inability to use the Services, including any indirect or consequential damages.

**6. Data Privacy:**
Your use of the Services is also governed by our Privacy Policy, which outlines how we collect, use, and share your personal information.

**7. Modification of Terms:**
We may modify or update these Terms at any time. Any changes will be posted in the app and will be effective immediately upon posting.

**8. Governing Law:**
These Terms are governed by the laws of [Your Country/State]. Any disputes arising from these Terms will be resolved in the appropriate jurisdiction.

**9. Contact Us:**
If you have any questions or concerns regarding these Terms, please contact us at: support@piggu.com
              ''',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

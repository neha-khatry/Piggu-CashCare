import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: TextStyle(fontFamily: 'Roboto')),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Privacy Policy',
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

Piggu:Cashcare values your privacy. This Privacy Policy explains how we collect, use, and share information about you when you use our mobile application, services, and features (the "Services"). 

By using Piggu:Cashcare, you consent to the practices described in this policy.

**1. Information We Collect:**
We may collect the following types of information:
- Personal Information: Your name, email address, phone number, and other information you provide.
- Usage Information: Information about how you use the Services, including device data, IP address, and log data.
- Transaction Information: Details about your financial transactions and receipt uploads.

**2. How We Use Your Information:**
We use the information we collect to:
- Provide and improve our services.
- Send you notifications about your account, updates, and promotional content.
- Analyze how our app is used to enhance the user experience.

**3. Sharing Your Information:**
We may share your information in the following ways:
- With service providers who assist in providing our Services.
- If required by law, such as in response to legal requests or regulatory obligations.

**4. Data Security:**
We take reasonable precautions to protect your personal information. However, no method of transmission over the internet or electronic storage is 100% secure.

**5. Your Choices:**
You can manage your account information, update your profile, and change privacy settings at any time.

**6. Changes to This Policy:**
We may update this Privacy Policy from time to time. Any changes will be posted in the app and will take effect immediately upon posting.

**7. Contact Us:**
If you have any questions about this Privacy Policy, please contact us at: support@piggu.com
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

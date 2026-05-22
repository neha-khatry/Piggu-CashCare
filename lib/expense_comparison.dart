import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/django_service.dart'; // Ensure this service fetches data from Django API


class ExpenseComparisonDialog {
  static Future<void> show(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while loading
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: fetchComparisonData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text('Expense Comparison'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Fetching data...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            String message = snapshot.data != null && snapshot.data!.containsKey('message')
                ? snapshot.data!['message']
                : 'No comparison data available.';

            return AlertDialog(
              title: Text('Expense Comparison'),
              content: Text(message, textAlign: TextAlign.center),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    show(context); // Refresh data
                  },
                  child: Text('Refresh'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to fetch comparison data
  static Future<Map<String, dynamic>?> fetchComparisonData() async {
    try {
      final djangoService = DjangoService();
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID is not available.');
      }

      return await djangoService.fetchExpenseComparison(userId);
    } catch (e) {
      return {'message': 'Error fetching comparison data.'};
    }
  }
}

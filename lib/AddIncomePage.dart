import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'EditIncomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:piggu/services/api_service.dart'; // Import ApiService


class AddIncomePage extends StatefulWidget {
  @override
  _AddIncomePageState createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _incomeSourceController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instance of ApiService


  Map<String, Map<String, dynamic>> _incomeCategories = {
    'Salary': {'icon': Icons.work, 'description': 'Salary'},
    'Rental': {'icon': Icons.home, 'description': 'Rental'},
    'Investment': {'icon': Icons.trending_up, 'description': 'Investment'},
    'Lottery': {'icon': Icons.casino, 'description': 'Lottery'},
    'Refunds': {'icon': Icons.receipt, 'description': 'Refunds'},
    'Rewards': {'icon': Icons.star, 'description': 'Rewards'},
    'Cashbacks': {'icon': Icons.credit_card, 'description': 'Cashbacks'},
    'Interest': {'icon': Icons.percent, 'description': 'Interest'},
    'Others': {'icon': Icons.more_horiz, 'description': 'Others'},
  };

  // Add income to Firebase in user's income subcollection
  Future<void> _addIncomeToFirebase(String source, double amount) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in')),
        );
        return;
      }
      DateTime timestamp = DateTime.now(); // Current date and time

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('income')
          .add({
        'source': source,
        'amount': amount,
        'timestamp': timestamp, // Add timestamp to the document
      });


      // Clear the form fields
      _incomeSourceController.clear();
      _incomeAmountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add income: $e')),
      );
    }
  }

  // Call ApiService to send income data to PostgreSQL
  Future<void> _addIncomeToPostgres(String userId, String source, double amount) async {
    try {
      final timestamp = DateTime.now().toIso8601String(); // Get current timestamp

      // Call ApiService to send income data to PostgreSQL
      bool success = await _apiService.sendIncomeData(userId, amount, source, timestamp);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Income added to PostgreSQL successfully')),
        );
      } else {
        throw Exception('Failed to add income to PostgreSQL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add income to PostgreSQL: $e')),
      );
    }
  }

  // Helper function to format the date (for history view)
  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Income'),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _incomeSourceController,
                      decoration: InputDecoration(
                        labelText: 'Income Source',
                        labelStyle: TextStyle(color: Colors.pink),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the income source';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _incomeAmountController,
                      decoration: InputDecoration(
                        labelText: 'Income Amount',
                        labelStyle: TextStyle(color: Colors.pink),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the income amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No user is logged in')),
                            );
                            return;
                          }
                          final incomeSource = _incomeSourceController.text;
                          final incomeAmount = double.parse(_incomeAmountController.text);

                          // Add to Firebase and PostgreSQL
                          _addIncomeToFirebase(incomeSource, incomeAmount);
                          _addIncomeToPostgres(userId, incomeSource, incomeAmount);
                        }
                      },
                      child: Text('Add Income'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),

              // Category Grid
              Scrollbar(
                child: GridView.builder(
                  itemCount: _incomeCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final category = _incomeCategories.keys.elementAt(index);
                    final icon = _incomeCategories[category]!['icon'];
                    return GridTile(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(icon),
                            color: Colors.pink,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Enter amount for $category'),
                                    content: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Amount',
                                        labelStyle: TextStyle(color: Colors.pink),
                                      ),
                                      onChanged: (value) {
                                        _incomeAmountController.text = value;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _incomeSourceController.text = category;
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Add Income'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pink,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          Text(category),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),

              // Real-time Income List with StreamBuilder
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('income')
                    .orderBy('timestamp', descending: true)
                    .snapshots(), // Firestore stream listens for real-time updates
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  final incomeList = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: incomeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final income = incomeList[index];
                      // Get the timestamp field and convert it to DateTime
                      final timestamp = (income['timestamp'] as Timestamp).toDate();
                      return ListTile(
                        title: Text(income['source']),
                        subtitle: Text(
                          'Amount: NPR ${income['amount']} \nDate: ${_formatDate(timestamp)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditIncomePage(
                                      incomeSource: income['source'],
                                      incomeAmount: income['amount'],
                                      onEdit: (source, amount) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth.instance.currentUser!.uid)
                                            .collection('income')
                                            .doc(income.id)
                                            .update({
                                          'source': source,
                                          'amount': amount,
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

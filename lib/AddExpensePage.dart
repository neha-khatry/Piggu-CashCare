import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'EditExpensePage.dart';
import 'services/api_service.dart'; // Import the ApiService

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _expenseSourceController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Predefined expense categories with icons and descriptions
  Map<String, Map<String, dynamic>> _expenseCategories = {
    'Grocery': {
      'icon': Icons.local_grocery_store,
      'description': 'Grocery and food expenses'
    },
    'Rent': {'icon': Icons.home, 'description': 'Rent and housing expenses'},
    'Household': {
      'icon': Icons.home_work,
      'description': 'Household and home maintenance expenses'
    },
    'Education': {
      'icon': Icons.school,
      'description': 'Education and tuition expenses'
    },

    'Health and Fitness': {
      'icon': Icons.local_hospital,
      'description': 'Health and medical expenses'
    },
    'Clothing': {
      'icon': FontAwesomeIcons.shirt,
      'description': 'Clothing and apparel expenses'
    },
    'Travel': {
      'icon': Icons.flight_takeoff,
      'description': 'Travel and transportation expenses'
    },
    'Electronics': {
      'icon': Icons.computer,
      'description': 'Electronics and gadget expenses'
    },
    'Others': {
      'icon': Icons.more_horiz,
      'description': 'Other miscellaneous expenses'
    },
  };

  // Helper function to format the date and time
  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Expense'),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Expense Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _expenseSourceController,
                      decoration: InputDecoration(
                        labelText: 'Expense Source',
                        labelStyle: TextStyle(color: Colors.pink),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the expense source';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _expenseAmountController,
                      decoration: InputDecoration(
                        labelText: 'Expense Amount',
                        labelStyle: TextStyle(color: Colors.pink),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the expense amount';
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
                          final expenseSource = _expenseSourceController.text;
                          final expenseAmount = double.parse(
                              _expenseAmountController.text);
                          _addExpense(expenseSource, expenseAmount);
                          _expenseSourceController.clear();
                          _expenseAmountController.clear();
                        }
                      },
                      child: Text('Add Expense'),
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
                  itemCount: _expenseCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final category = _expenseCategories.keys.elementAt(index);
                    final icon = _expenseCategories[category]!['icon'];
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
                                        labelStyle: TextStyle(
                                            color: Colors.pink),
                                      ),
                                      onChanged: (value) {
                                        _expenseAmountController.text = value;
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
                                          _expenseSourceController.text =
                                              category;
                                          Navigator.of(context).pop();
                                          // Optionally, trigger the add expense action here
                                        },
                                        child: Text('Add Expense'),
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
                          Text(
                            category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              // Real-time Expense List with StreamBuilder
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('expenses')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  final expenses = snapshot.data?.docs ?? [];
                  if (expenses.isEmpty) {
                    return Text('No expenses added yet.');
                  }

                  return ListView.builder(
                    itemCount: expenses.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final timestamp = expense['timestamp'] as Timestamp;

                      return ListTile(
                        title: Text(expense['source']),
                        subtitle: Text(
                          'Amount: NPR ${expense['amount']} \nDate: ${_formatDate(
                              timestamp)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditExpensePage(
                                          expenseSource: expense['source'],
                                          expenseAmount: expense['amount'],
                                          onEdit: (source, amount) {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(FirebaseAuth.instance
                                                .currentUser!.uid)
                                                .collection('expenses')
                                                .doc(expense.id)
                                                .update({
                                              'source': source,
                                              'amount': amount,
                                            });
                                            // Optionally, update in PostgreSQL as well
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

  // Add expense to both Firebase Firestore and PostgreSQL
  void _addExpense(String source, double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    // Save to Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add({
      'source': source,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Save to PostgreSQL via ApiService
    try {
      final timestamp = DateTime.now().toIso8601String();
      bool success = await _apiService.sendExpenseData(userId,
          amount, source, timestamp);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense added to PostgreSQL successfully')),
        );
      } else {
        throw Exception('Failed to add expense to PostgreSQL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense to PostgreSQL: $e')),
      );
    }
  }
}



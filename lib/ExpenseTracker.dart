import 'package:flutter/material.dart';
import 'AddExpensePage.dart';

class ExpenseTrackerPage extends StatefulWidget {
  @override
  _ExpenseTrackerPageState createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  double totalExpenses = 0.0; // Variable to keep track of total expenses

  void _addExpense(double amount) {
    setState(() {
      totalExpenses += amount; // Update total expenses
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: Center(
        child: Text(
          'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}', // Display total expenses
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpensePage()// Pass the callback
            ),
          ).then((value) {
            // Optional: you could handle any additional logic when returning to this page
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

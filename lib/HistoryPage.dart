import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'GraphsPage.dart'; // Import the GraphsPage

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, List<Map<String, dynamic>>> _groupedHistory = {};
  DateTime? _selectedDate;
  final User user = FirebaseAuth.instance.currentUser!; // Access current user
  Map<String, double> monthlyIncome = {};
  Map<String, double> monthlyExpenses = {};

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    try {
      // Fetching income data for the current user
      QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)  // Access the user's document by their UID
          .collection('income')  // Access the 'income' subcollection
          .get();
      print('Income Data: ${incomeSnapshot.docs.length} items fetched');

      // Fetching expense data for the current user
      QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)  // Access the user's document by their UID
          .collection('expenses')  // Access the 'expenses' subcollection
          .get();
      print('Expense Data: ${expenseSnapshot.docs.length} items fetched');

      // Combining income and expense data
      List<Map<String, dynamic>> history = [
        ...incomeSnapshot.docs.map((doc) {
          print("Income: ${doc.data()}"); // Debug
          return {
            'id': doc.id,
            'type': 'Income',
            'source': doc['source'],
            'amount': doc['amount'],
            'timestamp': doc['timestamp'],
          };
        }).toList(),
        ...expenseSnapshot.docs.map((doc) {
          print("Expense: ${doc.data()}"); // Debug
          return {
            'id': doc.id,
            'type': 'Expense',
            'source': doc['source'],
            'amount': doc['amount'],
            'timestamp': doc['timestamp'],
          };
        }).toList(),
      ];

      Map<String, List<Map<String, dynamic>>> groupedHistory = {};

      // Grouping history data by date
      for (var item in history) {
        String formattedDate =
        DateFormat('yyyy-MM-dd').format((item['timestamp'] as Timestamp).toDate());
        if (!groupedHistory.containsKey(formattedDate)) {
          groupedHistory[formattedDate] = [];
        }
        groupedHistory[formattedDate]!.add(item);

        // Accumulate monthly income and expenses for graphs
        String timeKey =
        DateFormat('yyyy-MM').format((item['timestamp'] as Timestamp).toDate());
        if (item['type'] == 'Income') {
          monthlyIncome[timeKey] = (monthlyIncome[timeKey] ?? 0) + item['amount'];
        } else if (item['type'] == 'Expense') {
          monthlyExpenses[timeKey] = (monthlyExpenses[timeKey] ?? 0) + item['amount'];
        }
      }

      // Update state with fetched data
      setState(() {
        _groupedHistory = groupedHistory;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'filter_date':
        _pickDateFilter();
        break;
      case 'graphs_charts':
        _navigateToGraphsPage();
        break;
    }
  }

  Future<void> _pickDateFilter() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Navigate to GraphsPage and pass monthlyIncome and monthlyExpenses
  void _navigateToGraphsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GraphsPage(
          user: user,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> filteredHistory = _selectedDate != null
        ? Map.fromEntries(
      _groupedHistory.entries.where((entry) =>
      entry.key == DateFormat('yyyy-MM-dd').format(_selectedDate!)),
    )
        : _groupedHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.pink,
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDateFilter,
            tooltip: 'Filter by Date',
          ),
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: _navigateToGraphsPage,
            tooltip: 'View Graphs/Charts',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Transaction History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            if (_selectedDate != null)
              Text(
                'Filtered by: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            Expanded(
              child: _groupedHistory.isEmpty
                  ? Center(child: Text("No transaction history available."))
                  : ListView(
                children: filteredHistory.entries.map((entry) {
                  String date = entry.key;
                  List<Map<String, dynamic>> items = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                      ...items.map((historyItem) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            title: Text(
                              historyItem['source'],
                              style: TextStyle(
                                color: historyItem['type'] == 'Income'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Amount: NPR ${historyItem['amount']}',
                              style: TextStyle(
                                color: historyItem['type'] == 'Income'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            trailing: Icon(
                              historyItem['type'] == 'Income'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: historyItem['type'] == 'Income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

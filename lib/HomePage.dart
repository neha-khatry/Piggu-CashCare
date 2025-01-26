import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'package:piggu/AddIncomePage.dart' as IncomePage; // Aliased import
import 'package:piggu/AddExpensePage.dart' as ExpensePage; // Aliased import
import 'GoalsPage.dart';
import 'AccountPage.dart';
import 'receipt_scanner.dart';
import 'HistoryPage.dart';
import 'NotificationsPage.dart';
import 'PredictionPage.dart'; // Import PredictionPage

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double balance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToFinancialData();
  }

  void _listenToFinancialData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('income')
        .snapshots()
        .listen((snapshot) {
      double income = snapshot.docs.fold(0.0, (sum, doc) => sum + (doc['amount'] ?? 0.0));
      setState(() {
        totalIncome = income;
        balance = totalIncome - totalExpenses;
        isLoading = false;
      });
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .listen((snapshot) {
      double expenses = snapshot.docs.fold(0.0, (sum, doc) => sum + (doc['amount'] ?? 0.0));
      setState(() {
        totalExpenses = expenses;
        balance = totalIncome - totalExpenses;
        isLoading = false;
      });
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _navigateToHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _showProfileOptions() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 50, 0, 0),
      items: [
        PopupMenuItem(
          child: Text('Account'),
          value: 'account',
        ),
        PopupMenuItem(
          child: Text('History'),
          value: 'history',
        ),
        PopupMenuItem(
          child: Text('Log out'),
          value: 'logout',
        ),
      ],
      elevation: 8.0,
    ).then<void>((String? value) {
      if (value != null) {
        switch (value) {
          case 'account':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountPage(user: widget.user)),
            );
            break;
          case 'history':
            _navigateToHistoryPage();
            break;
          case 'logout':
            _logout(context);
            break;
        }
      }
    });
  }

  void _scanReceipt() async {
    final receiptData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReceiptScanner()),
    );

    if (receiptData != null && receiptData['total_amount'] != null) {
      setState(() {
        balance += receiptData['total_amount'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final themeData = ThemeData(
      primaryColor: Colors.pink,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.pink.shade900),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: _buildCustomAppBar(),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildBalanceCard(),
              SizedBox(height: 20),
              _buildSummaryCards(),
              SizedBox(height: 20),
              _buildActionGrid(), // Action grid with Prediction added
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: themeData.primaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.pink.shade100,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                _navigateToHistoryPage();
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage(user: widget.user)),
                );
                break;
            }
          },
        ),
      ),
    );
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 30, width: 30),
          SizedBox(width: 8),
          Text(
            'Piggu: CashCare',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Pacifico',
            ),
          ),
        ],
      ),
      backgroundColor: Colors.pink,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    Color cardColor = balance >= 0 ? Colors.green.shade300 : Colors.red.shade300;

    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardColor.withOpacity(0.9), cardColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text('Current Balance', style: TextStyle(fontSize: 22, color: Colors.white)),
            SizedBox(height: 10),
            Text('NPR ${balance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryCard('Income', totalIncome, Colors.green),
        _buildSummaryCard('Expenses', totalExpenses, Colors.red),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 18, color: color)),
              SizedBox(height: 8),
              Text(
                'NPR ${amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildActionButton(Icons.add, 'Add Income', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => IncomePage.AddIncomePage()));
        }, Colors.green.shade300),
        _buildActionButton(Icons.remove, 'Add Expense', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExpensePage.AddExpensePage()));
        }, Colors.red.shade300),
        _buildActionButton(Icons.camera, 'Scan Receipt', _scanReceipt, Colors.purple.shade300),
        _buildActionButton(Icons.flag, 'Goals', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoalSettingPage(user: widget.user)),
          );
        }, Colors.blue.shade300),
        _buildActionButton(Icons.insights, 'Prediction', () {
          Navigator.pushNamed(context, '/prediction'); // Navigate to PredictionPage
        }, Colors.orange.shade300),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 4,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}

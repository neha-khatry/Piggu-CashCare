import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'AddIncomePage.dart';
import 'AddExpensePage.dart';
import 'GoalsPage.dart';
import 'AccountPage.dart';
import 'receipt_scanner.dart';
import 'HistoryPage.dart';

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

  // Function to listen to financial data (income and expenses) from Firestore
  void _listenToFinancialData() {
    final userId = widget.user.uid;

    // Listen to income subcollection
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('income')
        .snapshots()
        .listen((incomeSnapshot) {
      double income = incomeSnapshot.docs.fold(
        0.0,
            (sum, doc) => sum + (doc['amount'] ?? 0.0),
      );

      // Listen to expenses subcollection after fetching income
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .snapshots()
          .listen((expenseSnapshot) {
        double expenses = expenseSnapshot.docs.fold(
          0.0,
              (sum, doc) => sum + (doc['amount'] ?? 0.0),
        );

        // Update the state with total income, expenses, and balance
        setState(() {
          totalIncome = income;
          totalExpenses = expenses;
          balance = totalIncome - totalExpenses; // Calculate the balance
          isLoading = false;
        });
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

  void _navigateToNotificationsPage(BuildContext context) {
    // TODO: Implement navigation to NotificationsPage
  }

  void _navigateToHistoryPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _showProfileOptions(BuildContext context) {
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
            _navigateToHistoryPage(context);
            break;
          case 'logout':
            _logout(context);
            break;
        }
      }
    });
  }

  void _scanReceipt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReceiptScanner()),
    );
  }

  void onAddIncome(double amount) {
    setState(() {
      totalIncome += amount;
      balance += amount;
    });
  }

  void onAddExpense(double amount) {
    setState(() {
      totalExpenses += amount;
      balance -= amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final ThemeData themeData = ThemeData(
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
        appBar: AppBar(
          title: Text('Dashboard'),
          backgroundColor: Colors.pink,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () => _navigateToNotificationsPage(context),
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showProfileOptions(context),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildBalanceCard(),
                SizedBox(height: 20),
                _buildSummaryCards(),
                SizedBox(height: 20),
                _buildActionGrid(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: themeData.primaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.pink.shade100,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              _navigateToHistoryPage(context);
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage(user: widget.user)),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade900, Colors.pink.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('Current Balance', style: TextStyle(fontSize: 22, color: Colors.white)),
          SizedBox(height: 10),
          Text(
            'NPR ${balance.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
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
            Text('NPR ${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddIncomePage()));
        }),
        _buildActionButton(Icons.remove, 'Add Expense', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpensePage()));
        }),
        _buildActionButton(Icons.camera, 'Scan Receipt', () {
          _scanReceipt(context);
        }),
        _buildActionButton(Icons.flag, 'Goals', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GoalSettingPage(user: widget.user)));
        }),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}

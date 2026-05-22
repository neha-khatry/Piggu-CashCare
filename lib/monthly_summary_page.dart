import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/django_service.dart';
import 'graphspage.dart';
import 'homepage.dart';

class MonthlySummaryPage extends StatefulWidget {
  @override
  _MonthlySummaryPageState createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  Uint8List? monthlyIncomeChartData;
  Uint8List? monthlyExpenseChartData;
  bool isLoading = true;
  String comparisonMessage = 'Loading comparison data...';

  @override
  void initState() {
    super.initState();
    _fetchCharts();
    _fetchComparisonData();
  }

  Future<void> _fetchCharts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final djangoService = DjangoService();
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID is not available.');
      }

      final chartData = await djangoService.fetchMonthlyChart(userId);

      setState(() {
        monthlyIncomeChartData = base64Decode(chartData['income_chart']!);
        monthlyExpenseChartData = base64Decode(chartData['expense_chart']!);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chart: $e')),
      );
    }
  }

  Future<void> _fetchComparisonData() async {
    try {
      final djangoService = DjangoService();
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID is not available.');
      }

      final comparisonData = await djangoService.fetchExpenseComparison(userId);

      setState(() {
        comparisonMessage = comparisonData != null && comparisonData.containsKey('message')
            ? comparisonData['message']
            : 'No comparison data available.';
      });
    } catch (e) {
      setState(() {
        comparisonMessage = 'Error fetching comparison data.';
      });
    }
  }

  void _navigateToHome() {
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(user: user!)),
    );
  }

  void _navigateToGraphPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GraphPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Income vs Expense (By Month)'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateToHome,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      comparisonMessage,
                      style: TextStyle(fontSize: 16, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? CircularProgressIndicator(color: Colors.blue)
                : Column(
              children: [
                if (monthlyIncomeChartData != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(monthlyIncomeChartData!),
                  ),
                if (monthlyExpenseChartData != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(monthlyExpenseChartData!),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToGraphPage,
        label: Text("By Source"),
        icon: Icon(Icons.pie_chart),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

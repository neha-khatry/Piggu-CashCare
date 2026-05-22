import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/django_service.dart';
import 'monthly_summary_page.dart';
import 'homepage.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  Uint8List? incomeChartData;
  Uint8List? expenseChartData;
  String? sourceComparisonMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCharts();
    _fetchSourceComparison();
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

      final chartData = await djangoService.fetchChartData(userId);

      setState(() {
        incomeChartData = base64Decode(chartData['income_chart']!);
        expenseChartData = base64Decode(chartData['expense_chart']!);
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

  Future<void> _fetchSourceComparison() async {
    try {
      final djangoService = DjangoService();
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID is not available.');
      }

      final sourceComparison = await djangoService.fetchSourceExpenseComparison(userId);
      setState(() {
        sourceComparisonMessage = sourceComparison != null && sourceComparison.containsKey('message')
            ? sourceComparison['message']
            : 'No comparison data available.';
      });
    } catch (e) {
      setState(() {
        sourceComparisonMessage = 'Could not fetch expense comparison data.';
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

  void _navigateToMonthlySummary() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MonthlySummaryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income vs Expense (By Source)'),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateToHome,
        ),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.pink)
            : Column(
          children: [
            if (sourceComparisonMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber.shade700),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sourceComparisonMessage!,
                          style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (incomeChartData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(incomeChartData!),
              ),
            if (expenseChartData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(expenseChartData!),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToMonthlySummary,
        label: Text("By Month"),
        icon: Icon(Icons.calendar_today),
        backgroundColor: Colors.pink,
      ),
    );
  }
}

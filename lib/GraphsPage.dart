import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/django_service.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  Uint8List? incomeChartData;
  Uint8List? expenseChartData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCharts();
  }

  // Fetch chart data (base64-encoded strings) from the backend
  Future<void> _fetchCharts() async {
    setState(() {
      isLoading = true; // Show loader during fetch
    });

    try {
      final djangoService = DjangoService();

      // Get the current user's ID from Firebase
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? ''; // Use an empty string if user is null

      if (userId.isEmpty) {
        throw Exception('User ID is not available.');
      }

      final chartData = await djangoService.fetchChartData(userId);

      // Decode the base64 strings into Uint8List (bytes)
      setState(() {
        incomeChartData = base64Decode(chartData['income_chart']!);
        expenseChartData = base64Decode(chartData['expense_chart']!);
        isLoading = false; // Hide loader after successful fetch
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income vs Expense Charts'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.pink),
            SizedBox(height: 10),
            Text('Loading chart data...', style: TextStyle(color: Colors.grey)),
          ],
        )
            : Column(
          children: [
            if (incomeChartData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  incomeChartData!,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Failed to load income chart');
                  },
                ),
              ),
            if (expenseChartData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  expenseChartData!,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Failed to load expense chart');
                  },
                ),
              ),
            if (incomeChartData == null && expenseChartData == null)
              Text('No chart data available', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
        onPressed: _fetchCharts,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.pink,
      )
          : null, // Show refresh button only when not loading
    );
  }
}

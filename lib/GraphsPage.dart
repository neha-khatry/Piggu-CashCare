import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GraphsPage extends StatefulWidget {
  final User user;
  final Map<String, double> monthlyIncome;
  final Map<String, double> monthlyExpenses;

  GraphsPage({required this.user, required this.monthlyIncome, required this.monthlyExpenses});

  @override
  _GraphsPageState createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  late Map<String, double> monthlyIncome;
  late Map<String, double> monthlyExpenses;
  List<FlSpot> _incomeSpots = [];
  List<FlSpot> _expenseSpots = [];
  List<FlSpot> _incomeVsExpenseSpots = [];
  String _timePeriod = 'Monthly'; // Default to monthly

  @override
  void initState() {
    super.initState();
    monthlyIncome = widget.monthlyIncome;
    monthlyExpenses = widget.monthlyExpenses;

    // Initialize the spots
    _generateSpots();
  }

  // Function to generate FlSpot data
  void _generateSpots() {
    _incomeSpots = _generateSpotsFromData(monthlyIncome);
    _expenseSpots = _generateSpotsFromData(monthlyExpenses);
    _incomeVsExpenseSpots = _generateIncomeVsExpenseSpots();
  }

  List<FlSpot> _generateSpotsFromData(Map<String, double> data) {
    List<FlSpot> spots = [];
    int index = 0;
    data.forEach((key, value) {
      if (value != null && value > 0) { // Ensure data is non-zero and valid
        spots.add(FlSpot(index.toDouble(), value));
        index++;
      }
    });
    return spots;
  }

  // Generate spots for Income vs Expense
  List<FlSpot> _generateIncomeVsExpenseSpots() {
    List<FlSpot> spots = [];
    int index = 0;
    monthlyIncome.forEach((key, income) {
      double expense = monthlyExpenses[key] ?? 0;
      spots.add(FlSpot(index.toDouble(), income - expense));
      index++;
    });
    return spots;
  }

  // Filter data based on the time period
  void _filterDataByTimePeriod() {
    // Reset spots based on time period selection
    switch (_timePeriod) {
      case 'Daily':
      // Implement daily filtering logic (if available)
        break;
      case 'Weekly':
      // Implement weekly filtering logic (if available)
        break;
      case 'Monthly':
      // Already using monthly data
        break;
      case 'Yearly':
      // Implement yearly filtering logic (if available)
        break;
    }
    _generateSpots(); // Re-generate spots after filtering
  }

  // Dropdown for selecting time period
  Widget _buildTimePeriodDropdown() {
    return DropdownButton<String>(
      value: _timePeriod,
      items: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _timePeriod = newValue!;
          _filterDataByTimePeriod(); // Filter the data when time period changes
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graphs and Analysis'),
        backgroundColor: Colors.pink,
        elevation: 10,
        actions: [
          _buildTimePeriodDropdown(), // Time period dropdown
        ],
      ),
      body: SingleChildScrollView( // Wrap the entire body in a scroll view
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Income vs Expense',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Income Chart
              Text('Income', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildChart(_incomeSpots, Colors.green),
              SizedBox(height: 20),
              // Expense Chart
              Text('Expenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildChart(_expenseSpots, Colors.red),
              SizedBox(height: 20),
              // Income vs Expense Chart
              Text('Income vs Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildChart(_incomeVsExpenseSpots, Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  // Line chart widget for each graph
  Widget _buildChart(List<FlSpot> spots, Color color) {
    if (spots.isEmpty) {
      return Center(child: Text('No data available for the selected time range'));
    }

    return Container(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true, reservedSize: 40),
            bottomTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              colors: [color],
              barWidth: 3,
              belowBarData: BarAreaData(show: true, colors: [color.withOpacity(0.3)]),
            ),
          ],
        ),
      ),
    );
  }
}

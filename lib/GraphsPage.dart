import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphsPage extends StatelessWidget {
  final Map<String, List<double>> dailyIncome;
  final Map<String, List<double>> dailyExpenses;

  // Constructor to accept the dailyIncome and dailyExpenses data
  GraphsPage({required this.dailyIncome, required this.dailyExpenses});

  @override
  Widget build(BuildContext context) {
    // Convert dailyIncome and dailyExpenses to ChartData
    List<ChartData> incomeData = [];
    List<ChartData> expenseData = [];

    dailyIncome.forEach((day, incomes) {
      for (var income in incomes) {
        incomeData.add(ChartData(day, income, 0));
      }
    });

    dailyExpenses.forEach((day, expenses) {
      for (var expense in expenses) {
        expenseData.add(ChartData(day, 0, expense));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Income vs Expenses Graph'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Days')),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'Amount')),
          title: ChartTitle(text: 'Income vs Expenses'),
          legend: Legend(isVisible: true),
          series: <ChartSeries>[
            LineSeries<ChartData, String>(
              name: 'Income',
              dataSource: incomeData,
              xValueMapper: (ChartData data, _) => data.day,
              yValueMapper: (ChartData data, _) => data.income,
              color: Colors.green,
            ),
            LineSeries<ChartData, String>(
              name: 'Expense',
              dataSource: expenseData,
              xValueMapper: (ChartData data, _) => data.day,
              yValueMapper: (ChartData data, _) => data.expense,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to store chart data
class ChartData {
  final String day;
  final double income;
  final double expense;

  ChartData(this.day, this.income, this.expense);
}
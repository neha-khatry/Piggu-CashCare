import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartSample extends StatelessWidget {
  final double income;
  final double expenses;

  BarChartSample({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: (income > expenses ? income : expenses) * 1.2, // Adjust y-axis scale dynamically
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 12, color: Colors.black),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text(
                      'Income',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    );
                  case 1:
                    return Text(
                      'Expenses',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    );
                  default:
                    return Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: income,
                color: Colors.green,
                width: 20,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expenses,
                color: Colors.red,
                width: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

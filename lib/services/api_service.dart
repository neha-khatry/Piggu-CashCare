import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'http://10.0.2.2:8000/api'; // Local Django server

  // POST request for income data
  Future<bool> sendIncomeData(String userId, double amount, String source, String timestamp) async {
    final response = await http.post(
      Uri.parse('$apiUrl/income/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'amount': amount, 'source': source, 'timestamp': timestamp}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }

  // POST request for expense data
  Future<bool> sendExpenseData(double amount, String source, String timestamp) async {
    final response = await http.post(
      Uri.parse('$apiUrl/expense/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'source': source, 'timestamp': timestamp}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }

  // Fetch income and expense data for visualization
  Future<Map<String, double>> fetchIncomeExpenseData() async {
    try {
      final incomeResponse = await http.get(Uri.parse('$apiUrl/income/'));
      final expenseResponse = await http.get(Uri.parse('$apiUrl/expense/'));

      if (incomeResponse.statusCode == 200 && expenseResponse.statusCode == 200) {
        // Parse the income and expense data
        double totalIncome = 0.0;
        double totalExpense = 0.0;

        // Parse income data
        List incomeData = jsonDecode(incomeResponse.body);
        totalIncome = incomeData.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

        // Parse expense data
        List expenseData = jsonDecode(expenseResponse.body);
        totalExpense = expenseData.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

        return {'income': totalIncome, 'expenses': totalExpense};
      } else {
        // Log API response for debugging
        print('Income API response: ${incomeResponse.body}');
        print('Expense API response: ${expenseResponse.body}');
        throw Exception('Failed to fetch income and expense data. Status: ${incomeResponse.statusCode}, ${expenseResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching income and expense data: $e');
      return {'income': 0.0, 'expenses': 0.0}; // Default values in case of error
    }
  }

}

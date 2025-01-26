import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'http://10.0.2.2:8000/api'; // Local Django server for Android emulator

  // POST request for income data
  Future<bool> sendIncomeData(String userId, double amount, String source, String timestamp) async {
    final response = await http.post(
      Uri.parse('$apiUrl/income/'),  // Separate endpoint for income
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
  Future<bool> sendExpenseData(String userId, double amount, String source, String timestamp) async {
    final response = await http.post(
      Uri.parse('$apiUrl/expense/'),  // Separate endpoint for expense
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'amount': amount,
        'source': source,
        'timestamp': timestamp
      }),
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
        double totalIncome = 0.0;
        double totalExpense = 0.0;

        List incomeData = jsonDecode(incomeResponse.body);
        totalIncome = incomeData.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

        List expenseData = jsonDecode(expenseResponse.body);
        totalExpense = expenseData.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

        return {'income': totalIncome, 'expenses': totalExpense};
      } else {
        print('Income API response: ${incomeResponse.body}');
        print('Expense API response: ${expenseResponse.body}');
        throw Exception('Failed to fetch income and expense data. Status: ${incomeResponse.statusCode}, ${expenseResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching income and expense data: $e');
      return {'income': 0.0, 'expenses': 0.0};
    }
  }

  // Fetch prediction from the API
  Future<double> fetchPrediction(List<double> features) async {
    final response = await http.post(
      Uri.parse('$apiUrl/predict/'),  // Correct endpoint for prediction
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': features}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Prediction Response: $data');  // For debugging
      return data['prediction'][0]; // Assuming the API returns a prediction array
    } else {
      print('Error: ${response.body}'); // For debugging errors
      throw Exception('Failed to fetch prediction: ${response.body}');
    }
  }
}

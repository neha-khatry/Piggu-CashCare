import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'http://10.0.2.2:8000/api'; // Change this URL for production

  // POST request for income data
  Future<bool> sendIncomeData(double amount, String source, String timestamp) async {
    final response = await http.post(
      Uri.parse('$apiUrl/income/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'source': source, 'timestamp': timestamp}),
    );

    if (response.statusCode == 201) {
      // Data successfully created
      return true;
    } else {
      // Handle error
      print('Error: ${response.body}');
      return false;
    }
  }
  // Method to fetch income data from PostgreSQL
  Future<List<Map<String, dynamic>>> getIncomeData() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/income/'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch income data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching income data: $e');
      return [];
    }
  }

  // POST request for expense data
  Future<bool> sendExpenseData(double amount, String source) async {
    final response = await http.post(
      Uri.parse('$apiUrl/expense/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'source': source}),
    );

    if (response.statusCode == 201) {
      // Data successfully created
      return true;
    } else {
      // Handle error
      print('Error: ${response.body}');
      return false;
    }
  }
}



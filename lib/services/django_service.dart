import 'package:http/http.dart' as http;
import 'dart:convert';

class DjangoService {
  // Update the backend URL if necessary
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Change to your backend API URL

  // Method to save user to Django
  Future<void> saveUserToDjango(String userId, String email) async {
    final url = Uri.parse('$baseUrl/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId, 'email': email}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to save user to Django');
    }
  }

  // Method to fetch chart data (base64 encoded images for income and expense)
  Future<Map<String, String>> fetchChartData(String userId) async {
    try {
      final chartUrl = '$baseUrl/user-chart-data/'; // Endpoint for chart data
      final response = await http.get(
        Uri.parse(chartUrl),
        headers: {
          'User-ID': userId, // Send the user_id in the request header
        },
      );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = json.decode(response.body);

        // Extract income and expense charts (base64 strings)
        final incomeChart = data['charts']?['income_chart'] ?? '';
        final expenseChart = data['charts']?['expense_chart'] ?? '';

        // Check if both charts are valid base64 strings
        if (incomeChart is! String || expenseChart is! String) {
          throw Exception('Invalid chart data format');
        }

        // Return base64 strings for both charts
        return {
          'income_chart': incomeChart,
          'expense_chart': expenseChart,
        };
      } else {
        throw Exception('Failed to fetch chart data (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching chart data: $e');
      throw Exception('Error fetching chart data');
    }
  }
}

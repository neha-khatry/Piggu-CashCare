import 'package:http/http.dart' as http;
import 'dart:convert';

class DjangoService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

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



  Future<String> fetchChartUrl() async {
  final chartUrl = '$baseUrl/chart/'; // Endpoint for the chart
  return chartUrl; // Returning the chart URL
  }
}


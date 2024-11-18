import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Your Django API URL

  // Fetching Items
  Future<List<dynamic>> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items/'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

  // Creating an Item
  Future<void> createItem(String name, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/items/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, String>{
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create item');
      }
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String backendUrl = "http://10.0.2.2:8000/api/parse_sms/";

  Future<Map<String, dynamic>> sendMessageToBackend(String smsText) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "sms_text": smsText, // Updated key to match the backend
        }),
      ).timeout(
        const Duration(seconds: 10), // Set a timeout duration
        onTimeout: () {
          throw Exception("Request timed out. Please check your backend.");
        },
      );

      if (response.statusCode == 200) {
        // Parse and return the JSON response
        print("Message sent successfully: ${response.body}");
        return jsonDecode(response.body);
      } else {
        // Handle specific HTTP status codes
        print("Failed to send message: ${response.statusCode}");
        print("Error response: ${response.body}");
        return {
          "success": false,
          "error": "Failed with status code: ${response.statusCode}",
          "details": response.body,
        };
      }
    } catch (e) {
      // Handle errors gracefully
      print("Error while sending message: $e");
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
}

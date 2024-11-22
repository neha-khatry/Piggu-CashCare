import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> saveReceiptToServer({
  required String receiptNumber,
  required String receiptDate,
  required double totalAmount,
  required String merchantName,
  required String category,
}) async {
  final url = 'http://127.0.0.1:8000/api/save-receipt/';  // Your local Django server URL

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'receipt_number': receiptNumber,
      'receipt_date': receiptDate,
      'total_amount': totalAmount,
      'merchant_name': merchantName,
      'category': category,
    }),
  );

  if (response.statusCode == 201) {
    // Receipt saved successfully
    print('Receipt saved successfully!');
  } else {
    // Handle error
    print('Failed to save receipt: ${response.body}');
  }
}
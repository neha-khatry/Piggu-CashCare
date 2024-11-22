import 'package:flutter/material.dart';
import 'receipt_service.dart';  // Import the service file where you have saveReceiptToServer function

class ReceiptFormPage extends StatefulWidget {
  @override
  _ReceiptFormPageState createState() => _ReceiptFormPageState();
}

class _ReceiptFormPageState extends State<ReceiptFormPage> {
  final _receiptNumberController = TextEditingController();
  final _receiptDateController = TextEditingController();
  final _merchantNameController = TextEditingController();
  final _categoryController = TextEditingController();
  double _totalAmount = 0.0;

  void _submitReceipt() async {
    // Collect values from the form
    String receiptNumber = _receiptNumberController.text;
    String receiptDate = _receiptDateController.text;
    String merchantName = _merchantNameController.text;
    String category = _categoryController.text;

    // Call the function to save receipt data to the server
    await saveReceiptToServer(
      receiptNumber: receiptNumber,
      receiptDate: receiptDate,
      totalAmount: _totalAmount,
      merchantName: merchantName,
      category: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _receiptNumberController,
              decoration: InputDecoration(labelText: 'Receipt Number'),
            ),
            TextField(
              controller: _receiptDateController,
              decoration: InputDecoration(labelText: 'Receipt Date'),
            ),
            TextField(
              controller: _merchantNameController,
              decoration: InputDecoration(labelText: 'Merchant Name'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Amount'),
              onChanged: (value) {
                setState(() {
                  _totalAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReceipt,
              child: Text('Submit Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}
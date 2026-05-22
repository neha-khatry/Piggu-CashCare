import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ReceiptScannerApp());
}

class ReceiptScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Scanner',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.pink,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.pink.shade50,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.pink),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.pink.shade700),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.pink.shade700, // Pink SnackBars
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: ReceiptScanner(),
    );
  }
}

class ReceiptScanner extends StatefulWidget {
  @override
  _ReceiptScannerState createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends State<ReceiptScanner> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isReceiptUploaded = false;
  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isReceiptUploaded = true; // Enable details form
      });
    } else {
      _showSnackBar('No image selected.', Colors.red);
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _uploadImage(_selectedImage!.path);
      _parseOCRResult(response);
    } catch (e) {
      _showSnackBar('Error processing image: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/receipt-ocr/'), // Update endpoint
    );
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload image. Status code: ${response.statusCode}');
    }

    return responseData.body;
  }

  void _parseOCRResult(String result) {
    try {
      final data = json.decode(result);
      final extractedData = data['extracted_data'] ?? {};

      setState(() {
        _merchantController.text = extractedData['merchant'] ?? 'Unknown';
        _dateController.text = extractedData['timestamp'] ?? 'Unknown';
        _amountController.text = (double.tryParse(extractedData['total']?.toString() ?? '0.0') ?? 0.0).toStringAsFixed(2);
      });
    } catch (e) {
      _showSnackBar('Error parsing OCR data: $e', Colors.red);
    }
  }

  void _saveExtractedData() {
    final ApiService _apiService = ApiService();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final source = _categoryController.text.isNotEmpty ? _categoryController.text : 'Others';
    final timestamp = DateTime.now().toIso8601String();
    final receipt = {
      'merchant': _merchantController.text,
      'date': _dateController.text,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'source': _categoryController.text,
    };
    saveReceiptToFirebase(receipt);
    _apiService.sendExpenseData(userId, amount, source, timestamp);
    _showSnackBar('Receipt saved successfully!', Colors.green);
  }

  void saveReceiptToFirebase(Map<String, dynamic> receiptData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('receipts').add(receiptData);
      _showSnackBar('Receipt saved to Firebase successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error saving receipt to Firebase: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Scanner'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadSection(),
            if (_isReceiptUploaded) ...[
              SizedBox(height: 20),
              _buildDetailCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: _pickImageFromGallery,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.pink.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Column(
                  children: [
                    Icon(Icons.cloud_upload, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Tap to upload receipt',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.pink.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Merchant Name', _merchantController),
            _buildDetailRow('Date', _dateController),
            _buildDetailRow('Amount (NPR)', _amountController),
            _buildDetailRow('Category', _categoryController),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _processImage,
                  icon: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.play_arrow, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Process',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _saveExtractedData();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          ReceiptScanner()),
                    );
                  },
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink.shade800),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

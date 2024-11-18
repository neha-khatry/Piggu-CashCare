import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ReceiptScanner extends StatefulWidget {
  @override
  _ReceiptScannerState createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends State<ReceiptScanner> {
  final ImagePicker _picker = ImagePicker();
  String _extractedData = '';

  // Capture Image from Camera
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final result = await _uploadImage(image.path);
      setState(() {
        _extractedData = result; // Update UI with extracted data
      });
    }
  }

  // Pick Image from Gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final result = await _uploadImage(image.path);
      setState(() {
        _extractedData = result; // Update UI with extracted data
      });
    }
  }

  // Upload Image to Django
  Future<String> _uploadImage(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://YOUR_API_URL/receipt-ocr/'));
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    return responseData.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receipt Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImageFromCamera,
              child: Text('Scan Receipt from Camera'),
            ),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: Text('Upload Receipt from Gallery'),
            ),
            SizedBox(height: 20),
            Text('Extracted Data:'),
            Text(_extractedData),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictScreen extends StatefulWidget {
  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  double? prediction;
  final TextEditingController featureController = TextEditingController();

  Future<void> getPrediction() async {
    final url = Uri.parse('http://10.0.2.2:8000/predict/');
    final features = [double.parse(featureController.text)]; // Replace with your inputs

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'features': features}),
      );

      if (response.statusCode == 200) {
        setState(() {
          prediction = jsonDecode(response.body)['prediction'];
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Regression Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: featureController,
              decoration: InputDecoration(labelText: 'Feature Input'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: getPrediction,
              child: Text('Get Prediction'),
            ),
            if (prediction != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Prediction: $prediction', style: TextStyle(fontSize: 20)),
              ),
          ],
        ),
      ),
    );
  }
}

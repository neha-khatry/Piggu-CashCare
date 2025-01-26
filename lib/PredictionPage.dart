import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  double prediction = 0.0;
  String selectedCategory = 'Unknown';
  String recommendation = '';

  final List<String> categories = [
    'Groceries',
    'Dining',
    'Shopping',
    'Transport',
    'Utilities',
    'Unknown',
  ];

  Future<void> makePrediction() async {
    double income = double.tryParse(_incomeController.text) ?? 0.0;
    double expense = double.tryParse(_expenseController.text) ?? 0.0;
    double expenseToIncomeRatio = income != 0 ? expense / income : 0.0;

    if (income == 0.0 || expense == 0.0) {
      // Show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid income and expense values.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        prediction = 0.0; // Ensure no previous prediction is shown
        recommendation = ''; // Reset recommendation
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/predict/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'features': [
          1,
          income,
          expense,
          expenseToIncomeRatio,
          categories.indexOf(selectedCategory),
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        prediction = data['prediction'][0];
        recommendation = data['recommendation'];
      });
    } else {
      print('Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PREDICTION',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.pink[700],
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _incomeController,
                labelText: 'Enter Income',
                prefixIcon: Icons.money,
              ),
              SizedBox(height: 20),
              _buildInputField(
                controller: _expenseController,
                labelText: 'Enter Expense',
                prefixIcon: Icons.credit_card,
              ),
              SizedBox(height: 20),
              _buildDropdown(),
              SizedBox(height: 30),
              _buildButton('Get Prediction', makePrediction),
              SizedBox(height: 30),
              if (prediction != 0.0) _buildPredictionCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: labelText,  // This will apply to the text when the field is not focused.
          hintStyle: TextStyle(color: Colors.black), // Set hint text color to black
          prefixIcon: Icon(prefixIcon, color: Colors.pinkAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        onChanged: (String? newValue) {
          setState(() {
            selectedCategory = newValue!;
          });
        },
        items: categories.map<DropdownMenuItem<String>>((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category, style: TextStyle(fontSize: 16)),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Select Category',
          labelStyle: TextStyle(color: Colors.pinkAccent),
          prefixIcon: Icon(Icons.category, color: Colors.pinkAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildButton(String label, Function onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        shadowColor: Colors.pink[300],
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Card(
      elevation: 10,
      shadowColor: Colors.pink[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction: $prediction',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Recommendation: $recommendation',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class EditIncomePage extends StatefulWidget {
  final String incomeSource;
  final double incomeAmount;
  final Function(String, double) onEdit;

  EditIncomePage({
    required this.incomeSource,
    required this.incomeAmount,
    required this.onEdit,
  });

  @override
  _EditIncomePageState createState() => _EditIncomePageState();
}

class _EditIncomePageState extends State<EditIncomePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _incomeSourceController;
  late TextEditingController _incomeAmountController;

  @override
  void initState() {
    super.initState();
    _incomeSourceController = TextEditingController(text: widget.incomeSource);
    _incomeAmountController = TextEditingController(text: widget.incomeAmount.toString());
  }

  @override
  void dispose() {
    _incomeSourceController.dispose();
    _incomeAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Income'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _incomeSourceController,
                decoration: InputDecoration(
                  labelText: 'Income Source',
                  labelStyle: TextStyle(color: Colors.pink),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the income source';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _incomeAmountController,
                decoration: InputDecoration(
                  labelText: 'Income Amount',
                  labelStyle: TextStyle(color: Colors.pink),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the income amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedSource = _incomeSourceController.text;
                    final updatedAmount = double.parse(_incomeAmountController.text);

                    // Call the onEdit function to update the income
                    widget.onEdit(updatedSource, updatedAmount);

                    // Show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Income updated successfully')),
                    );

                    // Navigate back to the previous page
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Update Income'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

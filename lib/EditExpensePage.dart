import 'package:flutter/material.dart';

class EditExpensePage extends StatefulWidget {
  final String expenseSource;
  final double expenseAmount;
  final Function(String, double) onEdit;

  EditExpensePage({
    required this.expenseSource,
    required this.expenseAmount,
    required this.onEdit,
  });

  @override
  _EditExpensePageState createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _expenseSourceController;
  late TextEditingController _expenseAmountController;

  @override
  void initState() {
    super.initState();
    _expenseSourceController = TextEditingController(text: widget.expenseSource);
    _expenseAmountController = TextEditingController(text: widget.expenseAmount.toString());
  }

  @override
  void dispose() {
    _expenseSourceController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _expenseSourceController,
                decoration: InputDecoration(
                  labelText: 'Expense Source',
                  labelStyle: TextStyle(color: Colors.pink),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expense source';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expenseAmountController,
                decoration: InputDecoration(
                  labelText: 'Expense Amount',
                  labelStyle: TextStyle(color: Colors.pink),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expense amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onEdit(
                      _expenseSourceController.text,
                      double.parse(_expenseAmountController.text),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Save Changes'),
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

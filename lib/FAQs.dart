import 'package:flutter/material.dart';

void main() {
  runApp(FAQPageApp());
}

class FAQPageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAQs Page',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade600,
          centerTitle: true,
        ),
      ),
      home: FAQPage(),
    );
  }
}

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<Map<String, String>> faqData = [
    {'question': 'What is the SMS Parsing feature?', 'answer': 'This feature extracts transaction details like merchant name, date, and amount from your SMS messages.'},
    {'question': 'How do I add a new receipt?', 'answer': 'Tap the "Upload" button and select an image of your receipt.'},
    {'question': 'How do I categorize my expenses?', 'answer': 'Choose a category while reviewing the receipt data.'},
    {'question': 'How can I delete a receipt?', 'answer': 'Swipe left on the receipt in History and tap "Delete".'},
    {'question': 'How do I update my profile?', 'answer': 'Go to the Profile section and tap on "Edit".'},
    {'question': 'How do I view my expense history?', 'answer': 'Navigate to the History page to see your income and expenses.'},
    // Add more FAQ entries here
  ];

  List<Map<String, String>> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = faqData;
  }

  void filterFAQs(String query) {
    final filtered = faqData.where((faq) {
      return faq['question']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredData = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
        backgroundColor: Colors.pink.shade600,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterFAQs,
              decoration: InputDecoration(
                labelText: 'Search FAQs',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filteredData[index]['question']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          filteredData[index]['answer']!,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

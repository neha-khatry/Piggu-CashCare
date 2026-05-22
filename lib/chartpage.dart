import 'package:flutter/material.dart';
import 'GraphsPage.dart';

class ChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts Selection'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instructions or any additional UI here if needed
            Text(
              'Choose chart view based on:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Buttons to select between "Month" or "Source"
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GraphPage(), // Navigate to GraphPage
                  ),
                );
              },
              child: Text('View by Source'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GraphPage(), // Navigate to GraphPage
                  ),
                );
              },
              child: Text('View by Month'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            ),
          ],
        ),
      ),
    );
  }
}

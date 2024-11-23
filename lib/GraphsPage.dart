import 'package:flutter/material.dart';
import 'services/django_service.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String chartUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchChart();
  }

  Future<void> _fetchChart() async {
    try {
      final djangoService = DjangoService();
      final url = await djangoService.fetchChartUrl();

      setState(() {
        chartUrl = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income vs Expense Chart'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: chartUrl.isEmpty
            ? CircularProgressIndicator()
            : Image.network(
          chartUrl,
          errorBuilder: (context, error, stackTrace) {
            return Text('Failed to load chart');
          },
        ),
      ),
    );
  }
}



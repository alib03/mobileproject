import 'package:flutter/material.dart';

class ConversionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> conversionHistory;

  ConversionHistory({required this.conversionHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversion History'),
      ),
      body: ListView.builder(
        itemCount: conversionHistory.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> conversion = conversionHistory[index];
          return ListTile(
            title: Text(
              '${conversion['amount']} ${conversion['from']} = ${conversion['result']} ${conversion['to']}',
            ),
          );
        },
      ),
    );
  }
}

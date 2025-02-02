import 'package:flutter/material.dart';

class ResponsesForm extends StatelessWidget {
  final String requestID;
  const ResponsesForm({super.key, required this.requestID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Response'),
      ),
      body: Center(
        child: Text('form for $requestID'),
      ),
    );
  }
}

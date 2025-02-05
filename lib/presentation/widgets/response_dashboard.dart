import 'package:flutter/material.dart';

class ResponseDashboard extends StatefulWidget {
  final String responseID;

  const ResponseDashboard({super.key, required this.responseID});

  @override
  State<ResponseDashboard> createState() => _ResponseDashboardState();
}

class _ResponseDashboardState extends State<ResponseDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Response ID: ${widget.responseID}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

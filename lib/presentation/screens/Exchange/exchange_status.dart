import 'package:flutter/material.dart';

class ExchangeStatus extends StatefulWidget {
  const ExchangeStatus({super.key});

  @override
  State<ExchangeStatus> createState() => _ExchangeStatusState();
}

class _ExchangeStatusState extends State<ExchangeStatus> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("status page"),
      ),
    );
  }
}

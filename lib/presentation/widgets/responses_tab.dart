import 'package:flutter/material.dart';

class ResponsesTab extends StatefulWidget {
  const ResponsesTab({super.key});

  @override
  State<ResponsesTab> createState() => _ResponsesTabState();
}

class _ResponsesTabState extends State<ResponsesTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Center(
            child: Text('Responses Tab'),
          ),
        ),
      ],
    );
  }
}

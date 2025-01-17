import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'request_card.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  _RequestsTabState createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  late PocketBaseClient pbClient;
  late StreamSubscription<List<RecordModel>> subscription;
  List<RecordModel> requests = [];

  @override
  void initState() {
    super.initState();
    pbClient = PocketBaseClient(baseUrl: 'http://127.0.0.1:8090');

    subscription = pbClient.getLiveRequests().listen(
      (records) {
        setState(() {
          requests = records;
        });
      },
      onError: (error) {
        print('Error: $error');
      },
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    pbClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return ReqCard(request: requests[index]);
      },
    );
  }
}

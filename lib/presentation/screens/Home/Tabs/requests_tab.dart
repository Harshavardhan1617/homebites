import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_bites/presentation/screens/Home/Components/request_card.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:home_bites/services/pocketbase/requests_stream.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  late RequestsStreamController streamController;
  late StreamSubscription<List<RecordModel>> subscription;
  List<RecordModel> requests = [];

  @override
  void initState() {
    super.initState();
    final PocketBaseService pbClient =
        Provider.of<PocketBaseService>(context, listen: false);

    streamController = RequestsStreamController(
        pb: pbClient.pb, myId: pbClient.pb.authStore.record!.id);

    subscription = streamController.requestsStream.listen(
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
    streamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return ReqCard(request: requests[index]);
            },
          ),
        ),
      ],
    );
  }
}

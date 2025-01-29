import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_bites/presentation/screens/Forms/requests_form.dart';
import 'package:home_bites/presentation/screens/Home/Components/request_card.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:home_bites/services/pocketbase/stream.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  _RequestsTabState createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  late RequestsStreamController streamController;
  late StreamSubscription<List<RecordModel>> subscription;
  List<RecordModel> requests = [];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RequestsForm()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Get PocketBaseService from the provider
    final PocketBaseService pbClient =
        Provider.of<PocketBaseService>(context, listen: false);

    // Initialize the stream controller
    streamController = RequestsStreamController(pb: pbClient.pb);

    // Subscribe to the stream
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
    // Cancel the subscription and dispose of the stream controller
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Add',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.list),
                      label: 'View',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

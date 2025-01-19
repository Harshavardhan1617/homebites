import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'request_card.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  _RequestsTabState createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab>
    with AutomaticKeepAliveClientMixin {
  late PocketBaseClient pbClient;
  late StreamSubscription<List<RecordModel>> subscription;
  List<RecordModel> requests = [];
  // Keep track of selected index as a simple int
  int _selectedIndex = 0;

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

  void _onItemTapped(int index) {
    // Instead of rebuilding the whole widget, only rebuild the navigation bar
    _selectedIndex = index;
    // Force only the navigation bar to rebuild
    _navBarKey.currentState?.setState(() {});
  }

  // Create a global key for the navigation bar
  final GlobalKey<State<StatefulWidget>> _navBarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _CustomNavigationBar(
                  key: _navBarKey,
                  selectedIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Create a separate stateful widget for the navigation bar
class _CustomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<_CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'School',
        ),
      ],
      currentIndex: widget.selectedIndex,
      onTap: widget.onTap,
    );
  }
}

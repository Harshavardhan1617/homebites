import 'package:flutter/material.dart';
import 'package:home_bites/presentation/screens/Home/Components/request_card.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class MyRequestsTab extends StatefulWidget {
  const MyRequestsTab({super.key});

  @override
  State<MyRequestsTab> createState() => _MyRequestsTabState();
}

class _MyRequestsTabState extends State<MyRequestsTab> {
  late Future<ResultList<RecordModel>> _fetchedRequests;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final PocketBaseService pbService =
        Provider.of<PocketBaseService>(context, listen: false);
    _fetchedRequests =
        pbService.getMyRequests(pbService.pb.authStore.record!.id);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: FutureBuilder<ResultList<RecordModel>>(
        future: _fetchedRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final requests = snapshot.data!;
            return ListView.builder(
              itemCount: requests.totalItems,
              itemBuilder: (context, index) {
                final request = requests.items[index];
                return ReqCard(request: request);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:home_bites/presentation/providers/vars_provider.dart';
import 'package:home_bites/presentation/widgets/request_card.dart';
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
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final PocketBaseService pbService =
          Provider.of<PocketBaseService>(context, listen: false);
      _fetchedRequests =
          pbService.getMyRequests(pbService.pb.authStore.record!.id);

      // Update the int provider after the data is fetched
      final requestsCount =
          await _fetchedRequests.then((result) => result.totalItems);
      final intProvider = Provider.of<MyIntProvider>(context, listen: false);
      intProvider.updateInt(requestsCount);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching requests: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : FutureBuilder<ResultList<RecordModel>>(
                  future: _fetchedRequests,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final requests = snapshot.data!;
                      return ListView.builder(
                        itemCount: requests.totalItems,
                        itemBuilder: (context, index) {
                          final request = requests.items[index];
                          return ReqCard(request: request);
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
    );
  }
}

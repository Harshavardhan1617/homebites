import 'package:flutter/material.dart';
import 'package:home_bites/presentation/screens/Forms/responses_form.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class PublicResponses extends StatefulWidget {
  final String requestID;
  const PublicResponses({super.key, required this.requestID});

  @override
  State<PublicResponses> createState() => _PublicResponsesState();
}

class _PublicResponsesState extends State<PublicResponses> {
  Future<ResultList<RecordModel>> _fetchResponses() async {
    final PocketBaseService pb =
        Provider.of<PocketBaseService>(context, listen: false);
    return pb.getResponses(widget.requestID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Responses'),
      ),
      body: FutureBuilder<ResultList<RecordModel>>(
        future: _fetchResponses(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.items.length,
              itemBuilder: (context, index) {
                final response = snapshot.data!.items[index].data;
                return ListTile(title: Text(response['note']));
              },
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ResponsesForm(requestID: widget.requestID);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

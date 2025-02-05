import 'package:flutter/material.dart';
import 'package:home_bites/models/recieved_response_model.dart';
import 'package:home_bites/presentation/screens/Forms/responses_form.dart';
import 'package:home_bites/presentation/widgets/response_card.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:home_bites/services/pocketbase/responses_stream.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class PublicResponses extends StatefulWidget {
  final String requestID;
  final bool isMyRequest;
  const PublicResponses(
      {super.key, required this.requestID, this.isMyRequest = false});

  @override
  State<PublicResponses> createState() => _PublicResponsesState();
}

class _PublicResponsesState extends State<PublicResponses> {
  late ResponsesStream _responsesStream;

  @override
  void initState() {
    super.initState();
    final PocketBaseService pbService =
        Provider.of<PocketBaseService>(context, listen: false);
    _responsesStream =
        ResponsesStream(pb: pbService.pb, responseTo: widget.requestID);
  }

  @override
  void dispose() {
    _responsesStream.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _responsesStream.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Responses'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: StreamBuilder<List<RecordModel>>(
          stream: _responsesStream.responseStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  List<ReceivedResponseModel> responses =
                      snapshot.data!.map((record) {
                    return ReceivedResponseModel.fromRecord(record);
                  }).toList();
                  return ResponseCard(response: responses[index]);
                },
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: !widget.isMyRequest
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ResponsesFormScreen(requestID: widget.requestID),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

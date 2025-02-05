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
  late PocketBaseService pbService;

  @override
  void initState() {
    super.initState();
    pbService = Provider.of<PocketBaseService>(context, listen: false);
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

  bool checkIfResponded(List<ReceivedResponseModel> responses) {
    return responses.any(
      (response) => response.responseBy == pbService.pb.authStore.record!.id,
    );
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              List<ReceivedResponseModel> responses =
                  snapshot.data!.map((record) {
                return ReceivedResponseModel.fromRecord(record);
              }).toList();

              return ListView.builder(
                itemCount: responses.length,
                itemBuilder: (context, index) {
                  return ResponseCard(response: responses[index]);
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: StreamBuilder<List<RecordModel>>(
        stream: _responsesStream.responseStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ReceivedResponseModel> responses =
                snapshot.data!.map((record) {
              return ReceivedResponseModel.fromRecord(record);
            }).toList();

            bool haveIResponded = checkIfResponded(responses);

            if (!widget.isMyRequest && !haveIResponded) {
              return FloatingActionButton(
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
              );
            }
          }

          return const SizedBox.shrink(); // Empty widget when button not needed
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:home_bites/constants.dart';
import 'package:home_bites/models/exchange_model.dart';
import 'package:home_bites/models/recieved_response_model.dart';
import 'package:home_bites/presentation/widgets/not_my_response.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class ResponseCard extends StatefulWidget {
  final ReceivedResponseModel response;

  const ResponseCard({super.key, required this.response});

  @override
  State<ResponseCard> createState() => _ResponseCardState();
}

class _ResponseCardState extends State<ResponseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ReceivedResponseModel response = widget.response;
    final Map<String, dynamic> responseToData = response.expand['response_to'];
    final Map<String, dynamic> responseByData = response.expand['response_by'];
    String? avatarUrl = (responseByData['avatar'] != null &&
            responseByData['avatar'].toString().isNotEmpty)
        ? '$kPocketbaseHostUrl/api/files/${responseByData['collectionId']}/${responseByData['id']}/${responseByData['avatar']}'
        : null;
    PocketBaseService pbProvider =
        Provider.of<PocketBaseService>(context, listen: false);
    PocketBase pb = pbProvider.pb;
    String myID = pb.authStore.record!.id;
    bool isMyResponse = responseByData['id'] == myID;
    String ogRequestOwner = responseToData['requested_user'];
    bool isResponseToMe = ogRequestOwner == myID;
    bool isAccepted = response.status == 'accepted';
    log("is my order accpeted? $isAccepted");
    if (isMyResponse || (!isMyResponse && isResponseToMe)) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(responseByData['name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mobile: ${responseByData['mobile_number']}'),
              const SizedBox(height: 4),
              Text('Note: ${response.note}'),
              const SizedBox(height: 4),
              Text('Price: ${response.price}'),
              const SizedBox(height: 4),
              Text('Status: ${response.status}'),
            ],
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: _isExpanded
              ? [
                  !isResponseToMe
                      ? _EditAndDelete(response, pbProvider)
                      : !isAccepted
                          ? _acceptAndIgnore(response, pbProvider)
                          : Row(),
                ]
              : [],
        ),
      );
    }
    return NotMyResponse(avatarUrl: avatarUrl, response: response);
  }

  Widget _EditAndDelete(
      ReceivedResponseModel response, PocketBaseService pbProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            //TODO: Implement edit functionality here
          },
          child: const Text('Edit'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await pbProvider.deleteRecord(
                  collection: 'responses', id: response.id);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Response deleted successfully!')),
              );
            } on ClientException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Error deleting response: ${e.response['message']}')),
              );
              print(
                  'PocketBase ClientException: ${e.response['message']}, ${response.id}');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An error occurred: $e')),
              );
              print('An error occurred: $e');
            }
          },
          child: const Text('Delete'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _acceptAndIgnore(
      ReceivedResponseModel response, PocketBaseService pbProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () async {
            RecordModel? newExchange;
            try {
              newExchange = await pbProvider.createExchange(
                ExchangeModel(isAccepted: true),
              );
            } on ClientException catch (e) {
              log("error creating exchange $e ");
            }

            if (newExchange != null) {
              try {
                await pbProvider.updateRecord(
                  response.collectionName,
                  response.id,
                  {
                    'status': 'accepted',
                    'exchange_id': newExchange.id,
                    'response_to': response.responseTo,
                  },
                );
              } on ClientException catch (e) {
                log("error updating response with exchange id $e");
              }
            }
          },
          child: const Text('Accept'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Response Ignored successfully!')),
              );
            } on ClientException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Error Ignored response: ${e.response['message']}')),
              );
              print(
                  'PocketBase ClientException: ${e.response['message']}, ${response.id}');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An error occurred: $e')),
              );
              print('An error occurred: $e');
            }
          },
          child: const Text('Ignore'),
        ),
      ],
    );
  }
}

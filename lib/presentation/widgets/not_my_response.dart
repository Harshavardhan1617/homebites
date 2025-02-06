import 'package:flutter/material.dart';
import 'package:home_bites/models/recieved_response_model.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class NotMyResponse extends StatelessWidget {
  const NotMyResponse({
    super.key,
    required this.avatarUrl,
    required this.response,
  });

  final String? avatarUrl;
  final ReceivedResponseModel response;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> responseToData = response.expand['response_to'];
    final Map<String, dynamic> responseByData = response.expand['response_by'];

    PocketBase pb = Provider.of<PocketBaseService>(context, listen: false).pb;
    String myID = pb.authStore.record!.id;
    String ogRequestOwner = responseToData['requested_user'];
    bool isResponseToMe = ogRequestOwner == myID;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
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
            if (isResponseToMe) _responseStatus(response),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          isResponseToMe
              ? print("tap to respond")
              : print("this response is not for u");
        },
      ),
    );
  }

  Widget _responseStatus(ReceivedResponseModel response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("status: ${response.status}"),
        Text("exchange ID: ${response.exchange}"),
      ],
    );
  }
}
